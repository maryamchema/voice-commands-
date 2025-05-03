// lib/features/task_manager/presentation/pages/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assesment/features/task_manager/presentation/bloc/task_bloc.dart';
import 'package:task_assesment/features/task_manager/presentation/widgets/task_list.dart';
import 'package:task_assesment/features/task_manager/presentation/widgets/voice_fab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TaskBloc>().add(LoadTasks()),
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return TaskList(tasks: state.tasks);
          } else if (state is TaskError) {
            return Center(child: Text('Error: ${state.failure.message}'));
          }
          return const Center(child: Text('Press mic to add your first task'));
        },
      ),
      floatingActionButton: const VoiceFab(), // Correct usage
    );
  }
}
