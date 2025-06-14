import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade100;
    final accentColor = Colors.grey.shade600;
    return MaterialApp(
      title: 'todo app',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: baseColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black87,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.grey.shade800,
          ),
          iconTheme: IconThemeData(color: Colors.grey.shade800),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.grey.shade600,
          foregroundColor: Colors.white,
          elevation: 3,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(accentColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: accentColor),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accentColor,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum StatusTask { tuntas, belum }

class Task {
  final int? idTugas;
  final String namaTugas;
  final String deskripsi;
  final DateTime deadline;
  final StatusTask status;

  Task({
    this.idTugas,
    required this.namaTugas,
    required this.deskripsi,
    required this.deadline,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      idTugas: json['id_tugas'],
      namaTugas: json['nama_tugas'],
      deskripsi: json['deskripsi'],
      deadline: DateTime.parse(json['deadline']),
      status: json['status'] == 'tuntas' ? StatusTask.tuntas : StatusTask.belum,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tugas': idTugas,
      'nama_tugas': namaTugas,
      'deskripsi': deskripsi,
      'deadline': deadline.toIso8601String().split('T')[0],
      'status': status == StatusTask.tuntas ? 'tuntas' : 'belum',
    };
  }
}

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Sesuaikan dengan backendmu

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<bool> addTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateTask(Task task) async {
    if (task.idTugas == null) return false;
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.idTugas}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteTask(int id) async {
  final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));
  return response.statusCode == 200 || response.statusCode == 204;
}
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();

  List<Task> allTasks = [];
  List<Task> filteredTasks = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final tasks = await apiService.fetchTasks();
      tasks.sort((a, b) => a.deadline.compareTo(b.deadline)); // Urutkan deadline terdekat
      setState(() {
        allTasks = tasks;
        filteredTasks = tasks;
      });
    } catch (e) {
      // Error handling optional
    }
  }

  void filterTasks(String query) {
    final filtered = allTasks
        .where((task) =>
            task.namaTugas.toLowerCase().contains(query.toLowerCase().trim()))
        .toList();
    setState(() {
      filteredTasks = filtered;
    });
  }

  Future<void> toggleStatus(Task task) async {
    final newStatus =
        task.status == StatusTask.tuntas ? StatusTask.belum : StatusTask.tuntas;

    final updatedTask = Task(
      idTugas: task.idTugas,
      namaTugas: task.namaTugas,
      deskripsi: task.deskripsi,
      deadline: task.deadline,
      status: newStatus,
    );

    bool success = await apiService.updateTask(updatedTask);
    if (success) {
      fetchTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengubah status'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> deleteTask(int id) async {
    bool success = await apiService.deleteTask(id);
    if (success) {
      fetchTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menghapus tugas'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }
Future<void> showAddTaskDialog() async {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _selectedDate;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Tambah Tugas Baru', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Tugas',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _deskripsiController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setStateDialog(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Deadline',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Pilih Tanggal'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_namaController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Nama tugas harus diisi')),
                    );
                    return;
                  }
                  
                  if (_deskripsiController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deskripsi harus diisi')),
                    );
                    return;
                  }
                  
                  if (_selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deadline harus dipilih')),
                    );
                    return;
                  }

                  final newTask = Task(
                    namaTugas: _namaController.text,
                    deskripsi: _deskripsiController.text,
                    deadline: _selectedDate!,
                    status: StatusTask.belum,
                  );

                  bool success = await apiService.addTask(newTask);
                  if (!mounted) return;
                  if (success) {
                    Navigator.pop(context);
                    fetchTasks();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menambah tugas')),
                    );
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> showEditTaskDialog(Task task) async {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: task.namaTugas);
    final _deskripsiController = TextEditingController(text: task.deskripsi);
    DateTime _selectedDate = task.deadline;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Edit Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tugas',
                        prefixIcon: Icon(Icons.task),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Nama tugas wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Deskripsi wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Deadline',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate.toLocal().toString().split(' ')[0],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final updatedTask = Task(
                    idTugas: task.idTugas,
                    namaTugas: _namaController.text.trim(),
                    deskripsi: _deskripsiController.text.trim(),
                    deadline: _selectedDate,
                    status: task.status,
                  );

                  bool success = await apiService.updateTask(updatedTask);
                  if (success) {
                    Navigator.pop(context);
                    fetchTasks();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal memperbarui tugas')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: filterTasks,
              decoration: InputDecoration(
                hintText: 'Cari tugas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTasks,
        child: filteredTasks.isEmpty
            ? Center(
                child: Text(
                  'Tidak ada tugas',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  final isPastDeadline = task.deadline.isBefore(DateTime.now());
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Checkbox(
                        value: task.status == StatusTask.tuntas,
                        onChanged: (task.status == StatusTask.tuntas)
                            ? null
                            : (value) {
                                toggleStatus(task);
                              },
                      ),
                      title: Text(
                        task.namaTugas,
                        style: TextStyle(
                          decoration: task.status == StatusTask.tuntas
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.status == StatusTask.tuntas
                              ? Colors.grey.shade500
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            task.deskripsi,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: isPastDeadline &&
                                      task.status == StatusTask.belum
                                  ? Colors.red.shade700
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isPastDeadline && task.status == StatusTask.belum)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Deadline sudah lewat!',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: task.status == StatusTask.tuntas
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
                            onPressed: task.status == StatusTask.tuntas
                                ? null
                                : () => showEditTaskDialog(task),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade400,
                            ),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Konfirmasi'),
                                content: const Text('Hapus tugas ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      if (task.idTugas != null) {
                                        deleteTask(task.idTugas!);
                                      }
                                    },
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
        tooltip: 'Tambah tugas',
      ),
    );
  }
}
