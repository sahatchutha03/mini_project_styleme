import 'package:flutter/material.dart';
import '../models/styling_tip_model.dart';
import '../config/app_theme.dart';

class PersonalizedTipCard extends StatelessWidget {
  final StylingTip tip;
  final String bodyShape;

  const PersonalizedTipCard({
    super.key,
    required this.tip,
    required this.bodyShape,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัวการ์ด
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLightOf(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'คำแนะนำเฉพาะบุคคล (Personalized Tip)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'หุ่น $bodyShape',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // เนื้อหาคำแนะนำ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.tipTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tip.tipContent,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryOf(context),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // ไฮไลต์จุดเด่นของชุด
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightOf(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderOf(context)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'จุดเด่น: ${tip.highlightFeature}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (tip.luckyColorSynergy.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF332700) : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF665000) : Colors.amber.shade200,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: isDark ? const Color(0xFFFFD54F) : Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'พลังสีมงคล: ${tip.luckyColorSynergy}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFFFECB3) : Colors.brown.shade800,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
