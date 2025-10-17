import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  WalletConnect? _connector;
  String? _connectedAddress;
  bool _isConnected = false;

  WalletConnect? get connector => _connector;
  String? get connectedAddress => _connectedAddress;
  bool get isConnected => _isConnected;

  // Your WalletConnect Project ID
  final String _projectId = '1365f59596e09443b2f0b63f7686bdc6';

  Future<void> initializeWalletConnect() async {
    try {
      final session = await _getStoredSession();

      if (session != null) {
        // Restore existing session
        _connector = WalletConnect(
          bridge: 'https://bridge.walletconnect.org',
          session: session,
        );

        await _connector!.connect();
        _isConnected = true;
        _connectedAddress = _connector!.session.accounts?[0];
      } else {
        // Create new connector
        _connector = WalletConnect(
          bridge: 'https://bridge.walletconnect.org',
          clientMeta: const PeerMeta(
            name: 'Recycler App',
            description: 'Sustainable waste management with blockchain',
            url: 'https://recyclerapp.com',
            icons: [
              'https://raw.githubusercontent.com/WalletConnect/walletconnect-assets/master/Icon/Blue%20(Default)/Icon.png',
            ],
          ),
        );
      }

      // Set up event listeners with proper typing
      _connector!.on('connect', (session) {
        if (session is WalletConnectSession) {
          _isConnected = true;
          _connectedAddress = session.accounts?[0];
          _storeSession(session);
        }
      });

      _connector!.on('session_update', (session) {
        if (session is WalletConnectSession) {
          _isConnected = true;
          _connectedAddress = session.accounts?[0];
          _storeSession(session);
        }
      });

      _connector!.on('disconnect', (session) {
        _isConnected = false;
        _connectedAddress = null;
        _clearStoredSession();
      });
    } catch (e) {
      print('Error initializing WalletConnect: $e');
      _isConnected = false;
      _connectedAddress = null;
    }
  }

  Future<void> connectWallet() async {
    if (_connector == null) {
      await initializeWalletConnect();
    }

    if (_connector!.connected) {
      _isConnected = true;
      _connectedAddress = _connector!.session.accounts?[0];
      return;
    }

    try {
      // Create new session
      final session = await _connector!.createSession(
        chainId: 1, // Ethereum Mainnet
        onDisplayUri: (uri) async {
          // Open MetaMask with the connection URI
          await _launchMetaMask(uri);
        },
      );

      _isConnected = true;
      _connectedAddress = session.accounts?[0];
      await _storeSession(session as WalletConnectSession);
    } catch (e) {
      print('Error connecting wallet: $e');
      rethrow;
    }
  }

  Future<void> disconnectWallet() async {
    if (_connector != null && _connector!.connected) {
      await _connector!.killSession();
    }
    _isConnected = false;
    _connectedAddress = null;
    await _clearStoredSession();
  }

  Future<void> _launchMetaMask(String uri) async {
    final mobileUrl = 'metamask://wc?uri=${Uri.encodeComponent(uri)}';
    final webUrl =
        'https://metamask.app.link/wc?uri=${Uri.encodeComponent(uri)}';

    try {
      // Try to open MetaMask app
      if (await canLaunchUrl(Uri.parse(mobileUrl))) {
        await launchUrl(Uri.parse(mobileUrl));
      } else if (await canLaunchUrl(Uri.parse(webUrl))) {
        // Fallback to web version
        await launchUrl(Uri.parse(webUrl));
      } else {
        // Show QR code as fallback
        throw Exception('Please install MetaMask or use the QR code: $uri');
      }
    } catch (e) {
      // Show QR code as fallback
      throw Exception('Please install MetaMask or use the QR code: $uri');
    }
  }

  Future<void> _storeSession(WalletConnectSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'walletconnect_session',
      jsonEncode(session.toJson()),
    );
  }

  Future<WalletConnectSession?> _getStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('walletconnect_session');
    if (sessionJson != null) {
      try {
        final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
        return WalletConnectSession.fromJson(sessionMap);
      } catch (e) {
        print('Error parsing stored session: $e');
      }
    }
    return null;
  }

  Future<void> _clearStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('walletconnect_session');
  }

  // Get wallet balance (optional)
  Future<String> getWalletBalance() async {
    if (!_isConnected || _connectedAddress == null) {
      return '0';
    }

    try {
      // Use a free Ethereum RPC endpoint
      final web3client = Web3Client(
        'https://eth-mainnet.public.blastapi.io', // Free public RPC
        http.Client(), // Use http.Client instead of httpClient parameter
      );

      final address = EthereumAddress.fromHex(_connectedAddress!);
      final balance = await web3client.getBalance(address);

      // Close the client
      web3client.dispose();

      return (balance.getValueInUnit(EtherUnit.ether)).toStringAsFixed(4);
    } catch (e) {
      print('Error getting balance: $e');
      return 'Balance unavailable';
    }
  }

  // Alternative method using a simpler approach without web3dart
  Future<String> getWalletBalanceSimple() async {
    if (!_isConnected || _connectedAddress == null) {
      return '0';
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.etherscan.io/api?module=account&action=balance&address=$_connectedAddress&tag=latest&apikey=YourApiKeyToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == '1') {
          final weiBalance = BigInt.parse(data['result']);
          final etherBalance = weiBalance / BigInt.from(10).pow(18);
          return etherBalance.toStringAsFixed(4);
        }
      }
      return 'Balance unavailable';
    } catch (e) {
      print('Error getting balance: $e');
      return 'Balance unavailable';
    }
  }
}
