import 'package:flutter/material.dart';

class InfoBubble extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool stacked;
  final double? maxWidth;

  const InfoBubble({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  })  : stacked = false,
        maxWidth = null;

  const InfoBubble.stacked({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.maxWidth,
  }) : stacked = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = cs.outlineVariant.withOpacity(0.5);

    final content = stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                  ],
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth ?? 520),
                child: Text(
                  value.isEmpty ? '-' : value,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: cs.primary),
                const SizedBox(width: 6),
              ],
              Text('$label: ', style: Theme.of(context).textTheme.labelMedium),
              Flexible(
                child: Text(
                  value.isEmpty ? '-' : value,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: content,
    );
  }
}

class QuantityBubble extends StatelessWidget {
  final int quantity;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const QuantityBubble({
    super.key,
    required this.quantity,
    this.onMinus,
    this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Text('الكمية', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'إنقاص',
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline),
            style: IconButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
            ),
            child: Text('$quantity'),
          ),
          IconButton(
            tooltip: 'زيادة',
            onPressed: onPlus,
            icon: Icon(Icons.add_circle_outline, color: cs.primary),
            style: IconButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}

class StepperBubble extends StatelessWidget {
  final int value;
  final int max;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const StepperBubble({
    super.key,
    required this.value,
    required this.max,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = cs.outlineVariant.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Text('الكمية', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'زيادة',
            onPressed: value < max ? onInc : null,
            icon: Icon(Icons.add_circle_outline, color: cs.primary),
            style: IconButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Text(value.toString()),
          ),
          IconButton(
            tooltip: 'إنقاص',
            onPressed: value > 1 ? onDec : null,
            icon: const Icon(Icons.remove_circle_outline),
            style: IconButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}
