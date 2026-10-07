import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../config/app_theme.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final String currentBodyShape;
  final VoidCallback onTap;
  final String? heroTagPrefix;

  const OutfitCard({
    super.key,
    required this.outfit,
    required this.currentBodyShape,
    required this.onTap,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนรูปภาพพร้อม Badge
            Stack(
              children: [
                Hero(
                  tag: '${heroTagPrefix ?? "card"}-image-${outfit.id}',
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      outfit.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.checkroom, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Match Score Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Match ${outfit.matchScore}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Occasion Tag
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      outfit.occasion,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // รายละเอียดชุด
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          outfit.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // จุดสีมงคล
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse('FF${outfit.colorHex.replaceAll('#', '')}', radix: 16)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            outfit.colorName.split(' ').first,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondaryOf(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    outfit.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryOf(context),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // ไฮไลต์คำแนะนำเบื้องต้นสำหรับหุ่นที่เลือก
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLightOf(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tips_and_updates, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'เหมาะกับหุ่น $currentBodyShape: ${outfit.getTipForBodyShape(currentBodyShape).highlightFeature}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
