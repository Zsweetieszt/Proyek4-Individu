import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import '../onboarding/onboarding_view.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  // Controller untuk TextField di dialog
  // Dibuat di level State agar bisa dipakai di add DAN edit dialog
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Controller untuk search bar
  final TextEditingController _searchController = TextEditingController();

  // DAFTAR KATEGORI & WARNA
  static const List<String> _categories = [
    'Umum', 'Organisasi', 'Tugas', 'Kuliah', 'Pribadi', 'Urgent',
  ];

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Organisasi':   return Colors.blue;
      case 'Tugas':    return Colors.orange;
      case 'Kuliah': return Colors.green;
      case 'Pribadi':  return Colors.purple;
      case 'Urgent':   return Colors.red;
      default:         return Colors.blueGrey;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Dispose semua TextEditingController untuk cegah memory leak
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

  // DIALOG TAMBAH
  void _showAddLogDialog() {
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
                decoration:
                    const InputDecoration(hintText: 'Judul Catatan'),
              ),
              TextField(
                controller: _contentController,
                decoration:
                    const InputDecoration(hintText: 'Isi Deskripsi'),
              ),
              const SizedBox(height: 12),
              // Dropdown Kategori
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 6,
                          backgroundColor: _getCategoryColor(cat),
                        ),
                        const SizedBox(width: 10),
                        Text(cat),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedCategory = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validasi input kosong
                if (_titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul tidak boleh kosong!'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                // Panggil addLog di Controller
                _controller.addLog(
                  _titleController.text,
                  _contentController.text,
                  selectedCategory,
                );
                // Bersihkan input dan tutup dialog
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG EDIT
  void _showEditLogDialog(int index, LogModel log) {
    // Pre-fill dengan data yang sudah ada
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
              // Dropdown Kategori (Homework)
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 6,
                          backgroundColor: _getCategoryColor(cat),
                        ),
                        const SizedBox(width: 10),
                        Text(cat),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedCategory = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.updateLog(
                  index,
                  _titleController.text,
                  _contentController.text,
                  selectedCategory,
                );
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const OnboardingView()),
                (route) => false,
              );
            },
            child: const Text('Ya, Keluar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logbook: ${widget.username}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
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
          // Header selamat selimit
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: Colors.indigo.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(),
                    style: TextStyle(
                        fontSize: 13, color: Colors.indigo.shade400)),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _controller.searchLog(value),
              decoration: InputDecoration(
                labelText: 'Cari Catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _controller.searchLog('');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // ValueListenableBuilder dengan filteredLogs
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, currentLogs, child) {

                // EMPTY STATE
                if (currentLogs.isEmpty) {
                  final isSearching = _searchController.text.isNotEmpty;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: isSearching
                                  ? Colors.orange.shade50
                                  : Colors.indigo.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSearching
                                  ? Icons.search_off_rounded
                                  : Icons.menu_book_rounded,
                              size: 60,
                              color: isSearching
                                  ? Colors.orange.shade300
                                  : Colors.indigo.shade200,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isSearching
                                ? 'Catatan tidak ditemukan'
                                : 'Logbook masih kosong',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isSearching
                                ? 'Coba kata kunci yang berbeda'
                                : 'Ketuk tombol + untuk membuat\ncatatan pertamamu!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              height: 1.6,
                            ),
                          ),
                          if (!isSearching) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _showAddLogDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Buat Catatan Pertama'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                }

                // ListView.builder
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: currentLogs.length,
                  itemBuilder: (context, index) {
                    final log = currentLogs[index];
                    final categoryColor = _getCategoryColor(log.category);

                    // Geser untuk Hapus (Dismissible)
                    return Dismissible(
                      key: Key(log.date),
                      direction: DismissDirection.endToStart, // Kanan → Kiri
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white, size: 28),
                            SizedBox(height: 4),
                            Text('Hapus',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        final deletedTitle = log.title;
                        _controller.removeLog(index);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"$deletedTitle" dihapus'),
                            backgroundColor: Colors.red.shade400,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return true;
                      },

                      // Kotaknya berwarna sesuai kategori
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                  color: categoryColor, width: 5),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor:
                                  categoryColor.withOpacity(0.2),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              log.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (log.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    log.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    // Badge kategori
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        log.category,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.access_time,
                                        size: 11,
                                        color: Colors.grey.shade400),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        log.date,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Tombol Edit & Delete
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: categoryColor, size: 20),
                                  onPressed: () =>
                                      _showEditLogDialog(index, log),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () {
                                    _controller.removeLog(index);
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