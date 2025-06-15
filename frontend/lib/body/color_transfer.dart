import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:DokkaebieImage/constants/api_constants.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

class ColorTransferBody extends StatefulWidget {
  const ColorTransferBody({super.key});

  @override
  State<ColorTransferBody> createState() => _ColorTransferBodyState();
}

class _ColorTransferBodyState extends State<ColorTransferBody> {
  Map<String, Uint8List> _images = {};
  Uint8List? _referenceImage;
  String _apiResponseError = "";
  bool _isProcessing = false;
  Uint8List? _downloadableZip;

  void _downloadZipWithInterop(Uint8List bytes) {
    final blobPart = bytes.toJS;
    final jsArray = <web.BlobPart>[blobPart as web.BlobPart].toJS;

    final blob = web.Blob(
      jsArray,
      web.BlobPropertyBag(type: 'application/zip'),
    );
    final url = web.URL.createObjectURL(blob);

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = 'result.zip';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  Future<void> _pickReferenceImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _referenceImage = result.files.single.bytes!;
      });
    }
  }

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      Map<String, Uint8List> newImages = {};

      for (final file in result.files) {
        if (file.bytes != null) {
          newImages[file.name] = file.bytes!;
        }
      }

      setState(() {
        _images.addAll(newImages);
      });
    }
  }

  void _removeImage(String name) {
    setState(() {
      _images.remove(name);
    });
  }

  Future<void> _sendImagesAsZip() async {
    if (_images.isEmpty || _referenceImage == null) return;

    setState(() {
      _isProcessing = true;
      _downloadableZip = null;
    });

    final archive = Archive();
    archive.addFile(
      ArchiveFile('reference.byte', _referenceImage!.length, _referenceImage!),
    );
    for (final entry in _images.entries) {
      archive.addFile(
        ArchiveFile('targets/${entry.key}', entry.value.length, entry.value),
      );
    }

    final zippedData = ZipEncoder().encode(archive);
    final url = Uri.parse(ApiConstants.colorTransfer);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/zip'},
        body: Uint8List.fromList(zippedData),
      );

      if (response.statusCode == 200) {
        setState(() {
          _downloadableZip = response.bodyBytes;
        });
      }
    } catch (e) {
      setState(() {
        _apiResponseError = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _exampleImageWithLabel(String label, String assetPath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 188,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.asset(assetPath, fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              // Section 1
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'tool1_header'.tr(),
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tool1_contents'.tr(),
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Reference Image
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_referenceImage != null)
                          Container(
                            width: 340,
                            height: 340,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _referenceImage!,
                                width: 320,
                                height: 320,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _pickReferenceImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'tool1_upload_reference_image_btn'.tr(),
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Target Images
                    DottedBorder(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: _images.isEmpty
                              ? Text(
                                  'tool1_box_contents'.tr(),
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: _images.entries.map((entry) {
                                    final fname = entry.key;
                                    final imageData = entry.value;

                                    return Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            width: 150,
                                            height: 150,
                                            color: Colors.grey[200],
                                            child: Image.memory(
                                              imageData,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          color: Colors.red,
                                          onPressed: () => _removeImage(fname),
                                          splashRadius: 20,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Button to add target images
                    ElevatedButton(
                      onPressed: _pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'tool1_add_target_images_btn'.tr(),
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _sendImagesAsZip,
                          icon: const Icon(Icons.upload),
                          label: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'tool1_color_transfer_btn'.tr(),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent[200],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 25,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed:
                              (_downloadableZip != null && !_isProcessing)
                              ? () => _downloadZipWithInterop(_downloadableZip!)
                              : null,
                          icon: const Icon(Icons.download),
                          label: Text(
                            'tool1_download_btn'.tr(),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent[200],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 25,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (_apiResponseError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _apiResponseError,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),

              const SizedBox(height: 35),

              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'tool1_header2'.tr(),
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tool1_contents2'.tr(),
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Wrap(
                      spacing: 16,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        _exampleImageWithLabel(
                          'tool1_reference_img'.tr(),
                          "assets/images/tool1/ref.jpg",
                        ),
                        _exampleImageWithLabel(
                          'tool1_target_img'.tr(),
                          "assets/images/tool1/target.jpg",
                        ),
                        _exampleImageWithLabel(
                          'tool1_result_img'.tr(),
                          "assets/images/tool1/result.jpg",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '© 2025 Dokkaebi Image. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
