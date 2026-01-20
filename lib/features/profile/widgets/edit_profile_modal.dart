import 'dart:io';
import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileModal extends StatefulWidget {
  final AppUser user;
  final Future<void> Function({
    String? displayName,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) onSave;

  const EditProfileModal({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _profileImage;
  File? _coverImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.user.displayName;
    _bioController.text = widget.user.bio;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isCoverImage) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: isCoverImage ? 1920 : 1024,
        maxHeight: isCoverImage ? 1080 : 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (isCoverImage) {
            _coverImage = File(pickedFile.path);
          } else {
            _profileImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog(bool isCoverImage) async {
    final AppTheme t = AppTheme();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: t.primary),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isCoverImage);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: t.primary),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isCoverImage);
                },
              ),
              if ((isCoverImage && (_coverImage != null || widget.user.coverImageUrl != null)) ||
                  (!isCoverImage && (_profileImage != null || widget.user.photoUrl != null)))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover imagem'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      if (isCoverImage) {
                        _coverImage = null;
                      } else {
                        _profileImage = null;
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onSave(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        profileImage: _profileImage,
        coverImage: _coverImage,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme t = AppTheme();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      'Editar perfil',
                      style: t.heading18Bold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _handleSave,
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: t.primary,
                            ),
                          )
                        : Text(
                            'Salvar',
                            style: TextStyle(
                              color: t.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover Image
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _isLoading ? null : () => _showImageSourceDialog(true),
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: t.primary.withOpacity(0.3),
                                image: _coverImage != null
                                    ? DecorationImage(
                                        image: FileImage(_coverImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : widget.user.coverImageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(widget.user.coverImageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Editar capa',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Profile Image
                      Transform.translate(
                        offset: const Offset(0, -50),
                        child: Center(
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: _isLoading ? null : () => _showImageSourceDialog(false),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: t.primary,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    image: _profileImage != null
                                        ? DecorationImage(
                                            image: FileImage(_profileImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : widget.user.photoUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(widget.user.photoUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                  ),
                                  child: _profileImage == null && widget.user.photoUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 50,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _isLoading ? null : () => _showImageSourceDialog(false),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: t.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Form Fields
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Nome de exibição',
                              style: t.body14Bold,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _displayNameController,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                hintText: 'Digite seu nome de exibição',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: t.primary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nome de exibição é obrigatório';
                                }
                                if (value.trim().length < 3) {
                                  return 'Nome deve ter pelo menos 3 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Descrição',
                              style: t.body14Bold,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bioController,
                              enabled: !_isLoading,
                              maxLines: 4,
                              maxLength: 150,
                              decoration: InputDecoration(
                                hintText: 'Conte um pouco sobre você...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: t.primary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                counterText: '${_bioController.text.length}/150',
                              ),
                              validator: (value) {
                                if (value != null && value.length > 150) {
                                  return 'Descrição deve ter no máximo 150 caracteres';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Função helper para exibir o modal
Future<bool?> showEditProfileModal({
  required BuildContext context,
  required AppUser user,
  required Future<void> Function({
    String? displayName,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) onSave,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: EditProfileModal(
        user: user,
        onSave: onSave,
      ),
    ),
  );
}

