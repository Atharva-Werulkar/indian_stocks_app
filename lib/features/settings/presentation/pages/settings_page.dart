import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>();
      if (!settingsProvider.isInitialized) {
        settingsProvider.initialize();
      }
      _apiKeyController.text = settingsProvider.userApiKey;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (!settingsProvider.isInitialized) {
            return const Center(child: LoadingWidget());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildApiKeySection(settingsProvider),
                const SizedBox(height: 24),
                _buildAppearanceSection(settingsProvider),
                const SizedBox(height: 24),
                _buildNotificationSection(settingsProvider),
                const SizedBox(height: 24),
                _buildShareSection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
                const SizedBox(height: 24),
                _buildDangerZone(settingsProvider),
                const SizedBox(
                    height: 100), // Extra space for bottom navigation
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Settings',
        style: AppTheme.headingMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: _shareApp,
        ),
      ],
    );
  }

  Widget _buildApiKeySection(SettingsProvider settingsProvider) {
    return _buildSection(
      title: 'API Configuration',
      subtitle: 'Configure your TwelveData API key for real-time stock data',
      icon: Icons.api_rounded,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Get your free API key from TwelveData',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchUrl('https://twelvedata.com/pricing'),
                child: Text(
                  'Visit: https://twelvedata.com/pricing',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          title: const Text('Use Custom API Key'),
          subtitle: const Text('Enable to use your own TwelveData API key'),
          value: settingsProvider.useCustomApiKey,
          onChanged: (value) {
            settingsProvider.setUseCustomApiKey(value);
            if (!value) {
              _apiKeyController.clear();
              settingsProvider.setApiKey('');
            }
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        if (settingsProvider.useCustomApiKey) ...[
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                labelText: 'TwelveData API Key',
                hintText: 'Enter your API key here',
                prefixIcon: const Icon(Icons.key_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureApiKey = !_obscureApiKey;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: _pasteFromClipboard,
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (settingsProvider.useCustomApiKey &&
                    !settingsProvider.isValidApiKey(value ?? '')) {
                  return 'Please enter a valid API key';
                }
                return null;
              },
              onChanged: (value) {
                if (_formKey.currentState?.validate() ?? false) {
                  settingsProvider.setApiKey(value);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      settingsProvider.setApiKey(_apiKeyController.text);
                      _showToast('API key saved successfully');
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save API Key'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _apiKeyController.clear();
                  settingsProvider.clearApiKey();
                  _showToast('API key cleared');
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAppearanceSection(SettingsProvider settingsProvider) {
    final brightness = Theme.of(context).brightness;
    final isSystemDark = brightness == Brightness.dark;

    return _buildSection(
      title: 'Appearance',
      subtitle: 'Customize the app appearance',
      icon: Icons.palette_rounded,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSystemDark ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Theme',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      settingsProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SwitchListTile.adaptive(
          title: const Text('Dark Mode'),
          subtitle: Text(
            settingsProvider.isDarkMode
                ? 'Dark theme is enabled'
                : 'Light theme is enabled',
          ),
          value: settingsProvider.isDarkMode,
          onChanged: (value) {
            settingsProvider.setDarkMode(value);
            // Show a snackbar to confirm the change
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value ? 'Switched to Dark Mode' : 'Switched to Light Mode',
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
          activeColor: Theme.of(context).colorScheme.primary,
          secondary: Icon(
            settingsProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: settingsProvider.isDarkMode
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection(SettingsProvider settingsProvider) {
    return _buildSection(
      title: 'Notifications',
      subtitle: 'Manage notification preferences',
      icon: Icons.notifications_rounded,
      children: [
        SwitchListTile.adaptive(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive app notifications'),
          value: settingsProvider.enableNotifications,
          onChanged: settingsProvider.setNotificationsEnabled,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        SwitchListTile.adaptive(
          title: const Text('Price Alerts'),
          subtitle: const Text('Get notified about price changes'),
          value: settingsProvider.priceAlerts,
          onChanged: settingsProvider.enableNotifications
              ? settingsProvider.setPriceAlertsEnabled
              : null,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildShareSection() {
    return _buildSection(
      title: 'Share',
      subtitle: 'Share the app with others',
      icon: Icons.share_rounded,
      children: [
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share App'),
          subtitle: const Text('Tell your friends about Indian Stocks'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _shareApp,
        ),
        ListTile(
          leading: const Icon(Icons.rate_review),
          title: const Text('Rate App'),
          subtitle: const Text('Rate us on the app store'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _rateApp,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      subtitle: 'App information and support',
      icon: Icons.info_rounded,
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('App Version'),
          subtitle: Text(AppConstants.appVersion),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _launchUrl('https://yourapp.com/privacy'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _launchUrl('https://yourapp.com/terms'),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Report Bug'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () =>
              _launchUrl('mailto:support@yourapp.com?subject=Bug Report'),
        ),
      ],
    );
  }

  Widget _buildDangerZone(SettingsProvider settingsProvider) {
    return _buildSection(
      title: 'Danger Zone',
      subtitle: 'Irreversible actions',
      icon: Icons.warning_rounded,
      iconColor: Colors.red,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.refresh, color: Colors.red),
                title: Text('Reset All Settings'),
                subtitle: Text('This will clear all your preferences'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showResetDialog(settingsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.headingSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  void _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        _apiKeyController.text = clipboardData!.text!;
        _showToast('Pasted from clipboard');
      }
    } catch (e) {
      _showToast('Failed to paste from clipboard');
    }
  }

  void _shareApp() {
    Share.share(
      'Check out Indian Stocks - Your gateway to Indian stock market data!\n\n'
      'Track your favorite stocks, view detailed charts, and stay updated with real-time prices.\n\n'
      'Download now: https://play.google.com/store/apps/details?id=com.yourapp.indianstocks',
      subject: 'Indian Stocks App',
    );
  }

  void _rateApp() {
    _launchUrl(
        'https://play.google.com/store/apps/details?id=com.yourapp.indianstocks');
  }

  void _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showToast('Could not open link');
      }
    } catch (e) {
      _showToast('Failed to open link');
    }
  }

  void _showResetDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
          'Are you sure you want to reset all settings? This action cannot be undone.\n\n'
          'This will:\n'
          '• Clear your API key\n'
          '• Reset theme preferences\n'
          '• Reset notification settings\n'
          '• Clear all preferences',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              settingsProvider.resetSettings();
              _apiKeyController.clear();
              _showToast('Settings reset successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
    );
  }
}
