# Solana Multisig Wallet 🚀

A sophisticated Flutter application for managing Solana wallets with multi-signature functionality. This app provides a secure, user-friendly interface for handling Solana transactions, wallet management, and multi-signature operations on the Solana blockchain.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Solana](https://img.shields.io/badge/Solana-9945FF?style=for-the-badge&logo=solana&logoColor=white)

## 🌟 Features

### Core Wallet Functionality
- **Wallet Management**: Create, import, and manage multiple Solana wallets
- **Balance Display**: Real-time SOL balance tracking with automatic updates
- **Transaction History**: Complete transaction history with detailed information
- **Send/Receive**: Seamless SOL transfers with validation and confirmation
- **Address Validation**: Built-in Solana address format validation

### Multi-Signature Capabilities
- **Multisig Account Creation**: Set up multi-signature wallets with customizable thresholds
- **Transaction Proposals**: Create and propose transactions requiring multiple signatures
- **Signature Collection**: Secure signature collection from multiple parties
- **Pending Transactions**: Track and manage pending multisig transactions
- **Approval Workflow**: Complete approval workflow for multi-signature operations

### Advanced Features
- **Premium UI/UX**: Modern, gradient-based design with smooth animations
- **Secure Storage**: Encrypted local storage using Hive database
- **Transaction Validation**: Comprehensive transaction validation and error handling
- **Network Support**: Devnet support with configurable RPC endpoints
- **Memo Support**: Optional transaction memos for better record keeping
- **Airdrop Functionality**: Devnet SOL airdrop for testing purposes

## 📱 Screenshots

The app features a sleek, modern interface with:
- Dark theme with purple/blue gradient design
- Intuitive navigation with bottom tabs
- Real-time transaction status updates
- Premium styling with glassmorphism effects

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point with provider setup
├── providers/               # State management
│   ├── wallet_provider.dart   # Wallet state management
│   └── multisig_provider.dart # Multisig operations
├── services/               # Core services
│   ├── solana_service.dart    # Solana blockchain integration
│   └── storage_service.dart   # Local data persistence
├── screens/                # UI screens
│   ├── splash_screen.dart     # App initialization
│   └── home/                  # Main app screens
│       ├── wallet_tab.dart    # Wallet management UI
│       └── transactions_tab.dart # Transaction history
├── widgets/                # Reusable components
│   └── transaction_card.dart  # Transaction display cards
└── utils/                  # Utilities
    └── constants.dart         # App constants and strings
```

### State Management
- **Provider Pattern**: Uses Flutter Provider for state management
- **Reactive Updates**: Automatic UI updates when data changes
- **Separation of Concerns**: Clear separation between UI and business logic

### Data Persistence
- **Hive Database**: Fast, local NoSQL database for secure storage
- **Encrypted Storage**: Sensitive data encryption for security
- **Efficient Caching**: Optimized data retrieval and caching

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions
- Android emulator or iOS simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/solana-devs-mit/Flutter_Solana_App.git
   cd Flutter_Solana_App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies

Key packages used in this project:
- `provider`: State management solution
- `hive_flutter`: Local database for secure storage
- `http`: HTTP client for Solana RPC calls
- `crypto`: Cryptographic operations
- `lottie`: Beautiful animations
- `solana`: Solana blockchain integration

## 🔧 Configuration

### Network Configuration
The app is configured to use Solana Devnet by default. You can modify the network settings in `lib/utils/constants.dart`:

```dart
class AppConstants {
  static const String devnetUrl = 'https://api.devnet.solana.com';
  static const String mainnetUrl = 'https://api.mainnet-beta.solana.com';
  // ... other constants
}
```

### Multi-signature Settings
Default multisig configuration:
- **Maximum Signers**: 11
- **Minimum Signers**: 2
- **Default Threshold**: 2 signatures required

## 💡 Usage

### Creating a Wallet
1. Launch the app and complete the splash screen
2. Navigate to wallet creation
3. Generate a new wallet or import existing mnemonic
4. Secure your wallet with encryption

### Sending SOL
1. Go to the Wallet tab
2. Tap "Send" button
3. Enter recipient address and amount
4. Add optional memo
5. Confirm and sign transaction

### Multi-signature Operations
1. Create or join a multisig account
2. Propose transactions requiring multiple signatures
3. Collect signatures from required parties
4. Execute transactions when threshold is met

### Viewing Transactions
1. Navigate to Transactions tab
2. View complete history of all transactions
3. Track pending multisig transactions
4. Monitor transaction status and confirmations

## 🔒 Security Features

- **Private Key Encryption**: All private keys are encrypted locally
- **Secure Storage**: Hive database with encryption
- **Address Validation**: Comprehensive Solana address validation
- **Transaction Verification**: Multi-layer transaction validation
- **Network Security**: Secure RPC communication

## 🌐 Solana Integration

### RPC Methods Used
- `getBalance`: Retrieve wallet balances
- `getSignaturesForAddress`: Get transaction signatures
- `getTransaction`: Fetch detailed transaction data
- `sendTransaction`: Broadcast signed transactions
- `requestAirdrop`: Request devnet SOL (testing)
- `getAccountInfo`: Retrieve account information

### Transaction Processing
1. **Transaction Creation**: Build Solana transactions with proper instructions
2. **Signing**: Sign transactions with wallet private keys
3. **Broadcasting**: Send transactions to Solana network
4. **Confirmation**: Track transaction confirmation status

## 🛠️ Development

### Code Structure
- **Clean Architecture**: Separation of concerns with clear layers
- **Provider Pattern**: Reactive state management
- **Service Layer**: Abstracted blockchain interactions
- **Error Handling**: Comprehensive error handling and user feedback

### Testing
The project includes comprehensive error handling and validation:
- Input validation for addresses and amounts
- Network error handling
- Transaction failure recovery
- User feedback for all operations

### Performance Optimizations
- **Efficient State Updates**: Minimal rebuilds with targeted updates
- **Caching**: Smart caching of blockchain data
- **Background Processing**: Non-blocking operations for better UX

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Solana Foundation for blockchain infrastructure
- Flutter team for the amazing framework
- Open source contributors and the Solana developer community

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check existing documentation
- Review the code comments for implementation details

---

**Built with ❤️ using Flutter and Solana**

*This README reflects the current state of the application as analyzed from the codebase. The app provides a complete solution for Solana wallet management with multi-signature capabilities.*
