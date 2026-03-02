import 'package:flutter/material.dart';
import '../../services/mongo_services.dart';
import 'models/log_model.dart';
import '../onboarding/onboarding_view.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final MongoService _mongo = MongoService();

  // KEY: Future ini yang dikontrol untuk trigger refresh
  late Future<List<LogModel>> _logsFuture;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> _categories = [
    'Umum', 'Organisasi', 'Tugas', 'Kuliah', 'Pribadi', 'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  // Fungsi ini me-reset Future sehingga FutureBuilder rebuild
  void _refreshLogs() {
    setState(() {
      _logsFuture = _mongo.getLogs(username: widget.username);
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Organisasi': return Colors.blue;
      case 'Tugas':      return Colors.orange;
      case 'Kuliah':     return Colors.green;
      case 'Pribadi':    return Colors.purple;
      case 'Urgent':     return Colors.red;
      default:           return Colors.blueGrey;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  // DIALOG TAMBAH
  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    String selectedCategory = 'Umum';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Catatan Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Judul Catatan'),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(hintText: 'Isi Deskripsi'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(children: [
                    CircleAvatar(radius: 6, backgroundColor: _getCategoryColor(cat)),
                    const SizedBox(width: 10),
                    Text(cat),
                  ]),
                )).toList(),
                onChanged: (value) => setDialogState(() => selectedCategory = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Judul tidak boleh kosong!'),
                        backgroundColor: Colors.orange),
                  );
                  return;
                }
                final newLog = LogModel(
                  title: _titleController.text.trim(),
                  description: _contentController.text.trim(),
                  category: selectedCategory,
                  date: _formatDate(DateTime.now()),
                  username: widget.username,
                );
                await _mongo.insertLog(newLog);
                if (context.mounted) Navigator.pop(context);
                _refreshLogs(); // Auto-refresh setelah tambah
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG EDIT
  void _showEditLogDialog(LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    String selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController),
              TextField(controller: _contentController),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(children: [
                    CircleAvatar(radius: 6, backgroundColor: _getCategoryColor(cat)),
                    const SizedBox(width: 10),
                    Text(cat),
                  ]),
                )).toList(),
                onChanged: (value) => setDialogState(() => selectedCategory = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = LogModel(
                  id: log.id,
                  title: _titleController.text.trim(),
                  description: _contentController.text.trim(),
                  category: selectedCategory,
                  date: log.date,
                  username: log.username,
                );
                await _mongo.updateLog(updated);
                if (context.mounted) Navigator.pop(context);
                _refreshLogs(); // Auto-refresh setelah edit
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) => const OnboardingView()),
                  (route) => false);
            },
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logbook: ${widget.username}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _handleLogout),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: Colors.indigo.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(),
                    style: TextStyle(fontSize: 13, color: Colors.indigo.shade400)),
                Text(widget.username,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                labelText: 'Cari Catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // FutureBuilder — inti Task 3
          Expanded(
            child: FutureBuilder<List<LogModel>>(
              future: _logsFuture,
              builder: (context, snapshot) {

                // LOADING STATE
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Mengambil data dari Cloud...',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // ERROR STATE
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text('Gagal terhubung ke Cloud',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _refreshLogs,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Filter berdasarkan search
                final allLogs = snapshot.data ?? [];
                final currentLogs = _searchQuery.isEmpty
                    ? allLogs
                    : allLogs.where((log) =>
                        log.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                // EMPTY STATE
                if (currentLogs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              color: _searchQuery.isNotEmpty
                                  ? Colors.orange.shade50 : Colors.indigo.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off_rounded : Icons.menu_book_rounded,
                              size: 60,
                              color: _searchQuery.isNotEmpty
                                  ? Colors.orange.shade300 : Colors.indigo.shade200,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Catatan tidak ditemukan' : 'Data Kosong',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Coba kata kunci yang berbeda'
                                : 'Belum ada catatan di MongoDB Atlas.\nKetuk tombol + untuk membuat catatan pertama!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.6),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _showAddLogDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Buat Catatan Pertama'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                }

                // LIST DATA
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: currentLogs.length,
                  itemBuilder: (context, index) {
                    final log = currentLogs[index];
                    final categoryColor = _getCategoryColor(log.category);

                    return Dismissible(
                      key: Key(log.id?.toHexString() ?? log.date),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.red, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white, size: 28),
                            SizedBox(height: 4),
                            Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (log.id == null) return false;
                        await _mongo.deleteLog(log.id!);
                        _refreshLogs(); // Auto-refresh setelah hapus
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('"${log.title}" dihapus'),
                              backgroundColor: Colors.red.shade400,
                              duration: const Duration(seconds: 2)),
                        );
                        return true;
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(left: BorderSide(color: categoryColor, width: 5)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: categoryColor.withValues(alpha: 0.2),
                              child: Text('${index + 1}',
                                  style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(log.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (log.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(log.description, maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: categoryColor,
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Text(log.category,
                                          style: const TextStyle(fontSize: 10, color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.access_time, size: 11, color: Colors.grey.shade400),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(log.date,
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: categoryColor, size: 20),
                                  onPressed: () => _showEditLogDialog(log),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    if (log.id == null) return;
                                    await _mongo.deleteLog(log.id!);
                                    _refreshLogs();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}