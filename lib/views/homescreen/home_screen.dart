// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:recycler/utils/colors.dart';
// import 'package:recycler/views/admin/waste_categories.dart';
// import 'package:recycler/views/driver/driver.dart';
// import 'package:recycler/views/household/bottom_bar.dart';
// import 'package:recycler/widgets/test_action_button.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     final args = Get.arguments as Map<String, dynamic>?;
//     final String role = (args?['role'] ?? '').toString();

//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: width > 420 ? 420 : width),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(18),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.25),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.recycling,
//                       size: 86,
//                       color: AppColors.recycleIcon,
//                     ),
//                   ),
//                   const SizedBox(height: 22),
//                   const Text(
//                     'Recycler App',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Connect your wallet to continue',
//                     style: TextStyle(color: Colors.white70, fontSize: 15),
//                   ),
//                   const SizedBox(height: 22),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.connectButtonBg,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         elevation: 2,
//                       ),
//                       icon: const Icon(Icons.account_balance_wallet, size: 18),
//                       label: const Text('Connect Wallet'),
//                     ),
//                   ),

//                   const SizedBox(height: 26),
//                   const Text(
//                     'Test Login Options',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (role == 'household' || role.isEmpty)
//                     TestActionButton(
//                       label: 'Household',
//                       backgroundColor: AppColors.householdButton,
//                       foregroundColor: Colors.white,
//                       onPressed: () {
//                         Get.to(() => const BottomBar());
//                       },
//                     ),
//                   const SizedBox(height: 12),
//                   if (role == 'driver')
//                     TestActionButton(
//                       label: 'Driver',
//                       backgroundColor: AppColors.driverButton,
//                       foregroundColor: Colors.black87,
//                       onPressed: () {
//                         Get.to(() => Driver());
//                       },
//                     ),
//                   const SizedBox(height: 12),
//                   if (role == 'admin')
//                     TestActionButton(
//                       label: 'Admin',
//                       backgroundColor: AppColors.adminButton,
//                       foregroundColor: Colors.white,
//                       onPressed: () {
//                         Get.to(() => WasteCategories());
//                       },
//                     ),

//                   const SizedBox(height: 28),
//                   TestActionButton(
//                     label: 'Run Penalty Test Scenario',
//                     backgroundColor: AppColors.yellowButton.withOpacity(0.9),
//                     foregroundColor: Colors.black87,
//                     onPressed: null,
//                     disabledBackgroundColor: AppColors.yellowButton.withOpacity(
//                       0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:recycler/utils/colors.dart';
import 'package:recycler/views/admin/waste_categories.dart';
import 'package:recycler/views/driver/driver.dart';
import 'package:recycler/views/household/bottom_bar.dart';
import 'package:recycler/widgets/test_action_button.dart';
import 'package:recycler/services/wallet_service.dart';
import 'package:clipboard/clipboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WalletService _walletService = WalletService();
  bool _isConnecting = false;
  bool _isConnected = false;
  String _walletAddress = '';

  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }

  Future<void> _initializeWallet() async {
    await _walletService.initializeWalletConnect();
    if (_walletService.isConnected) {
      setState(() {
        _isConnected = true;
        _walletAddress = _walletService.connectedAddress!;
      });
    }
  }

  Future<void> _connectWallet() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await _walletService.connectWallet();
      
      setState(() {
        _isConnected = _walletService.isConnected;
        _walletAddress = _walletService.connectedAddress ?? '';
        _isConnecting = false;
      });

      if (_isConnected) {
        Get.snackbar(
          'Success!',
          'Wallet connected successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });
      
      Get.snackbar(
        'Connection Failed',
        'Failed to connect wallet: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _disconnectWallet() async {
    await _walletService.disconnectWallet();
    setState(() {
      _isConnected = false;
      _walletAddress = '';
    });
    
    Get.snackbar(
      'Disconnected',
      'Wallet disconnected successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _copyAddress() {
    if (_walletAddress.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _walletAddress));
      Get.snackbar(
        'Copied!',
        'Wallet address copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _formatAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final args = Get.arguments as Map<String, dynamic>?;
    final String role = (args?['role'] ?? '').toString();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width > 420 ? 420 : width),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 86,
                      color: AppColors.recycleIcon,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Recycler App',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Wallet Connection Status
                  if (_isConnected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Wallet Connected',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _copyAddress,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatAddress(_walletAddress),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.copy, size: 16, color: Colors.white70),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _disconnectWallet,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Disconnect Wallet'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Connect your wallet to continue',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                  
                  const SizedBox(height: 22),
                  
                  // Connect Wallet Button
                  if (!_isConnected)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isConnecting ? null : _connectWallet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isConnecting 
                              ? Colors.grey 
                              : AppColors.connectButtonBg,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        icon: _isConnecting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.account_balance_wallet, size: 18),
                        label: Text(
                          _isConnecting ? 'Connecting...' : 'Connect MetaMask',
                        ),
                      ),
                    ),

                  const SizedBox(height: 26),
                  
                  // Only show test options if wallet is connected
                  if (_isConnected) ...[
                    const Text(
                      'Test Login Options',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (role == 'household' || role.isEmpty)
                      TestActionButton(
                        label: 'Household',
                        backgroundColor: AppColors.householdButton,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          Get.to(() => const BottomBar());
                        },
                      ),
                    const SizedBox(height: 12),
                    if (role == 'driver')
                      TestActionButton(
                        label: 'Driver',
                        backgroundColor: AppColors.driverButton,
                        foregroundColor: Colors.black87,
                        onPressed: () {
                          Get.to(() => Driver());
                        },
                      ),
                    const SizedBox(height: 12),
                    if (role == 'admin')
                      TestActionButton(
                        label: 'Admin',
                        backgroundColor: AppColors.adminButton,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          Get.to(() => WasteCategories());
                        },
                      ),

                    const SizedBox(height: 28),
                    TestActionButton(
                      label: 'Run Penalty Test Scenario',
                      backgroundColor: AppColors.yellowButton.withOpacity(0.9),
                      foregroundColor: Colors.black87,
                      onPressed: null,
                      disabledBackgroundColor: AppColors.yellowButton.withOpacity(0.5),
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Please connect your wallet to access app features',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}