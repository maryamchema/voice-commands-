import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assesment/features/task_manager/presentation/bloc/task_bloc.dart';
import 'package:task_assesment/features/task_manager/presentation/widgets/task_list.dart';
import 'package:task_assesment/features/task_manager/presentation/widgets/voice_fab.dart';

import '../../../../core/errors/failures.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted task: ${state.title}')),
          );
        }
        if (state is TaskError && state.failure is CacheFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage error: ${state.failure.message}'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () =>
                    context.read<TaskBloc>().add(LoadTasks(refresh: true)),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<TaskBloc>().add(LoadTasks(refresh: true)),
            ),
          ],
        ),
        body: _buildBody(context),
        floatingActionButton: const VoiceFab(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          return TaskList(tasks: state.tasks);
        } else if (state is TaskEmpty) {
          return const Center(child: Text('No tasks available'));
        } else if (state is TaskError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.failure.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<TaskBloc>().add(LoadTasks(refresh: true)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
