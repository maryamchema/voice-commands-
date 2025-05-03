// lib/features/task_manager/presentation/widgets/voice_fab.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:task_assesment/features/task_manager/domain/services/llm_command_processor.dart';
import 'package:task_assesment/features/task_manager/presentation/bloc/task_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/services/command_processor.dart';
import '../../domain/services/llm_api_service.dart';

class VoiceFab extends StatefulWidget {
  const VoiceFab({super.key});

  @override
  State<VoiceFab> createState() => _VoiceFabState();
}

class _VoiceFabState extends State<VoiceFab> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  bool _hasFinalResult = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_lastWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _lastWords,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        FloatingActionButton(
          onPressed: _toggleRecording,
          tooltip: 'Voice Command',
          backgroundColor:
              _isListening ? Colors.red : Theme.of(context).primaryColor,
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
      ],
    );
  }

  Future<void> _toggleRecording() async {
    if (_isListening) {
      // Stop listening first
      await _speech.stop();
      setState(() => _isListening = false);

      // Wait a brief moment for final results to process
      await Future.delayed(const Duration(milliseconds: 300));

      // Only show "no command" if we never got any final results
      if (!_hasFinalResult && _lastWords.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No voice command detected")),
        );
      }

      setState(() {
        _lastWords = '';
        _hasFinalResult = false;
      });
    } else {
      // Start new recording session
      setState(() {
        _lastWords = '';
        _hasFinalResult = false;
      });

      final available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              if (result.finalResult) {
                _hasFinalResult = true;
                _processCommand(result.recognizedWords);
              }
            });
          },
          listenFor: const Duration(seconds: 20),
          cancelOnError: true,
          partialResults: true,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Voice recognition not available")),
        );
      }
    }
  }

  final llmService = LLMApiService(
    dio: Dio(),
  );

  Future<void> _processCommand(String voiceText) async {
    try {
      final Map<String, dynamic> result =
          await llmService.processCommand(voiceText);
      print('LLM result----------------------: $result');
      final action = result['action'];
      final title = result['title'];
      final oldTitle = result['oldTitle'];
      final description = result['description'] ?? '';
      final dateTimeStr = result['dateTime'];

      final DateTime? parsedDate =
          dateTimeStr != null ? DateTime.tryParse(dateTimeStr) : null;

      final bloc = context.read<TaskBloc>();
      if (action == 'create') {
        final task = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          oldTitle: title,
          description: description,
          scheduledTime: parsedDate ?? DateTime.now().add(Duration(minutes: 1)),
        );
        bloc.add(AddTaskEvent(task));
        return;
      }
      if (bloc.state is TaskLoaded) {
        final taskList = (bloc.state as TaskLoaded).tasks;

        switch (action) {
          // case 'create':
          //   final task = Task(
          //     id: DateTime.now().millisecondsSinceEpoch.toString(),
          //     title: title,
          //     oldTitle: title,
          //     description: description,
          //     scheduledTime: parsedDate ?? DateTime.now(),
          //   );
          //   bloc.add(AddTaskEvent(task));
          //   break;

          case 'update':
            final oldTitle = result['oldTitle']; // Extract oldTitle from LLM
            final title = result['title']; // Extract new title

            if (oldTitle != null && title != null) {
              final matchingTasks = taskList
                  .where((task) =>
                      task.title.trim().toLowerCase() ==
                      oldTitle.trim().toLowerCase())
                  .toList();

              if (matchingTasks.isNotEmpty) {
                final oldTask = matchingTasks.first;

                // Ensure we have a valid update time
                DateTime updatedTime =
                    parsedDate ?? DateTime.now().add(Duration(minutes: 1));
                if (updatedTime.isBefore(DateTime.now())) {
                  updatedTime = DateTime.now().add(Duration(minutes: 5));
                }

                final updatedTask = Task(
                  id: oldTask.id,
                  title: title,
                  oldTitle: oldTitle,
                  description: description,
                  scheduledTime: updatedTime,
                );

                bloc.add(UpdateTaskEvent(updatedTask));
              } else {
                _showError(
                    'Task with old title "$oldTitle" not found for update.');
              }
            } else {
              // Print more detailed error message
              _showError(
                  'Missing old title ("$oldTitle") or new title ("$title") for update.');
            }
            break;

          case 'delete':
            if (title != null) {
              final matchingTasks = taskList
                  .where((task) => task.title.trim() == title.trim())
                  .toList();

              if (matchingTasks.isNotEmpty) {
                final taskToDelete = matchingTasks.first;
                bloc.add(DeleteTaskEvent(taskToDelete.id));
              } else {
                _showError('Task with title "$title" not found for deletion.');
              }
            } else {
              _showError('Missing title for deletion.');
            }
            break;

          default:
            _showError('Unknown action: $action');
        }
      }
    } catch (e) {
      _showError('Failed to process command: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
