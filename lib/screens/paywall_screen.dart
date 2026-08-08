import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/score_providers.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/gradient_scaffold.dart';

/// 買い切りオファー画面。
/// RevenueCat未接続のため、購入ボタンは開発用のローカルisPremiumフラグ切替のみ
/// （実決済は行わない）。RevenueCat接続後は Purchases.purchasePackage(...) に置き換える。
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _processing = false;

  Future<void> _unlockForDev() async {
    setState(() => _processing = true);
    await ref.read(localProfileStoreProvider).setPremium(true);
    ref.invalidate(userProfileProvider);
    if (!mounted) return;
    setState(() => _processing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('開発用にアンロックしました（実決済なし）')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('プレミアムにアップグレード'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.workspace_premium, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              '一度払えば追加課金なし',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _FeatureRow(text: '基本20コース 全開放'),
                    _FeatureRow(text: 'わざと渋滞モード 解放'),
                    _FeatureRow(text: '巻き戻しリプレイ 無制限'),
                    _FeatureRow(text: '広告を完全に削除'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¥600（買い切り）',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '追加コースパックは ¥120 / 5コース で後から購入できます',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 24),
            Center(
              child: BouncyButton(
                label: _processing ? '処理中...' : '購入する（開発用）',
                icon: Icons.lock_open,
                onPressed: _processing ? () {} : _unlockForDev,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ RevenueCat未接続のため、実際の決済は発生しません（開発用フラグの切替のみ）',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;

  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
