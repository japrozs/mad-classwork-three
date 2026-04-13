import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'tasks',
  );

  // CREATE
  Future<void> addTask(String title) async {
    final task = Task(id: '', title: title.trim(), createdAt: DateTime.now());
    await _col.add(task.toMap());
  }

  // READ (real-time stream)
  Stream<List<Task>> streamTasks() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) =>
                    Task.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<void> toggleTask(Task task) async {
    await _col.doc(task.id).update({'isCompleted': !task.isCompleted});
  }

  // UPDATE
  Future<void> updateSubtasks(
    Task task,
    List<Map<String, dynamic>> subtasks,
  ) async {
    await _col.doc(task.id).update({'subtasks': subtasks});
  }

  // DELETE
  Future<void> deleteTask(String id) async {
    await _col.doc(id).delete();
  }
}
