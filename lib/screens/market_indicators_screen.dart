import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'package:financial_literacy_frontend/widgets/loading_spinner.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:async';

class CurrencyData {
  final String country;
  final String currency;
  final double ttRate;
  final double ddRate;
  final double buyingNotes;
  final double selling;
  final double sellingNotes;
  final String transactionDate;

  CurrencyData({
    required this.country,
    required this.currency,
    required this.ttRate,
    required this.ddRate,
    required this.buyingNotes,
    required this.selling,
    required this.sellingNotes,
    required this.transactionDate,
  });

  factory CurrencyData.fromXmlElement(XmlElement element) {
    return CurrencyData(
      country: element.findElements('country').first.innerText.trim(),
      currency: element.findElements('currency').first.innerText.trim(),
      ttRate: double.tryParse(element.findElements('tt').first.innerText) ?? 0.0,
      ddRate: double.tryParse(element.findElements('dd').first.innerText) ?? 0.0,
      buyingNotes: double.tryParse(element.findElements('buying-notes-').first.innerText) ?? 0.0,
      selling: double.tryParse(element.findElements('selling').first.innerText) ?? 0.0,
      sellingNotes: double.tryParse(element.findElements('sellingNotes-notes-').first.innerText) ?? 0.0,
      transactionDate: element.findElements('transactionDate').first.innerText.trim(),
    );
  }

  String get displayCurrency => currency.replaceAll(' 1', '');
  String get formattedTTRate => 'Rs ${ttRate.toStringAsFixed(2)}';
  String get formattedDDRate => 'Rs ${ddRate.toStringAsFixed(2)}';
  String get formattedBuyingNotes => 'Rs ${buyingNotes.toStringAsFixed(2)}';
  String get formattedSelling => 'Rs ${selling.toStringAsFixed(2)}';
  String get formattedSellingNotes => 'Rs ${sellingNotes.toStringAsFixed(2)}';
}

class MarketIndicatorsScreen extends StatefulWidget {
  const MarketIndicatorsScreen({super.key});

  @override
  State<MarketIndicatorsScreen> createState() => _MarketIndicatorsScreenState();
}

class _MarketIndicatorsScreenState extends State<MarketIndicatorsScreen>
    with TickerProviderStateMixin {
  List<CurrencyData> currencyData = [];
  bool isLoadingCurrencies = false;
  String? currencyError;
  Timer? _refreshTimer;
  String selectedTab = 'currencies'; // 'currencies', 'gold', 'commodities'

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  static const List<String> priorityCurrencies = [
    'USD', 'EUR', 'GBP', 'AUD', 'CAD', 'JPY', 'CHF', 'CNY', 'INR', 'SGD', 'ZAR'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchCurrencyData();
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _fetchCurrencyData();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrencyData() async {
    if (mounted) {
      setState(() {
        isLoadingCurrencies = true;
        currencyError = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('https://bom.mu/bom-xml-live'),
        headers: {'User-Agent': 'Mozilla/5.0 (compatible; Flutter App)'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        List<CurrencyData> fetchedData = [];
        for (var item in items) {
          try {
            final currency = CurrencyData.fromXmlElement(item);
            fetchedData.add(currency);
          } catch (e) {
            continue;
          }
        }

        // Enhanced sorting: Priority currencies first, then alphabetically
        fetchedData.sort((a, b) {
          final aPriority = priorityCurrencies.indexOf(a.displayCurrency);
          final bPriority = priorityCurrencies.indexOf(b.displayCurrency);

          if (aPriority != -1 && bPriority != -1) {
            return aPriority.compareTo(bPriority);
          } else if (aPriority != -1) {
            return -1;
          } else if (bPriority != -1) {
            return 1;
          } else {
            return a.displayCurrency.compareTo(b.displayCurrency);
          }
        });

        if (mounted) {
          setState(() {
            currencyData = fetchedData;
            isLoadingCurrencies = false;
          });
        }
      } else {
        throw Exception('Failed to load currency data: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currencyError = 'Failed to load currency rates. Please try again.';
          isLoadingCurrencies = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Indicators',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Live rates and market data',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: _fetchCurrencyData,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isLoadingCurrencies ? _pulseAnimation.value : 1.0,
                          child: Icon(
                            MdiIcons.refresh,
                            color: AppColors.white,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTabSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabItem('currencies', 'Currencies', MdiIcons.currencyUsd),
          _buildTabItem('gold', 'Gold', MdiIcons.gold),
          _buildTabItem('commodities', 'More', MdiIcons.chartLine),
        ],
      ),
    );
  }

  Widget _buildTabItem(String tabId, String label, IconData icon) {
    final isSelected = selectedTab == tabId;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = tabId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.white.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.white.withOpacity(0.8),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(CurrencyData currency, int index) {
    final isPriority = priorityCurrencies.contains(currency.displayCurrency);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPriority ? AppColors.secondary.withOpacity(0.3) : AppColors.border.withOpacity(0.5),
                  width: isPriority ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPriority
                                  ? [AppColors.secondary, AppColors.secondaryLight]
                                  : [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currency.displayCurrency,
                            style: AppTypography.h4.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.country,
                                style: AppTypography.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                currency.currency,
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isPriority)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  MdiIcons.star,
                                  color: AppColors.secondary,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Popular',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildRateItem(
                                  'Buying (TT)',
                                  currency.formattedTTRate,
                                  MdiIcons.trendingDown,
                                  AppColors.success,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.border.withOpacity(0.5),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              Expanded(
                                child: _buildRateItem(
                                  'Selling',
                                  currency.formattedSelling,
                                  MdiIcons.trendingUp,
                                  AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          if (currency.ddRate > 0 || currency.buyingNotes > 0) ...[
                            const SizedBox(height: 16),
                            Divider(color: AppColors.border.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (currency.ddRate > 0) ...[
                                  Expanded(
                                    child: _buildRateItem(
                                      'DD Rate',
                                      currency.formattedDDRate,
                                      MdiIcons.bank,
                                      AppColors.primary,
                                    ),
                                  ),
                                  if (currency.buyingNotes > 0) ...[
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: AppColors.border.withOpacity(0.5),
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ],
                                ],
                                if (currency.buyingNotes > 0) ...[
                                  Expanded(
                                    child: _buildRateItem(
                                      'Notes',
                                      currency.formattedBuyingNotes,
                                      MdiIcons.cashMultiple,
                                      AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRateItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.body1.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTypography.h4.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedTab) {
      case 'currencies':
        return _buildCurrenciesTab();
      case 'gold':
        return _buildGoldTab();
      case 'commodities':
        return _buildCommoditiesTab();
      default:
        return _buildCurrenciesTab();
    }
  }

  Widget _buildCurrenciesTab() {
    if (isLoadingCurrencies) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: LoadingSpinner(),
        ),
      );
    }

    if (currencyError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  MdiIcons.alertCircleOutline,
                  color: AppColors.error,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Unable to load currency rates',
                style: AppTypography.h4.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                currencyError!,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchCurrencyData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _fetchCurrencyData,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (currencyData.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(MdiIcons.informationOutline, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Updated: ${currencyData.first.transactionDate}',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'All rates are in Mauritian Rupees (MUR)',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ...currencyData.asMap().entries.map((entry) {
                return _buildCurrencyCard(entry.value, entry.key);
              }),
            ] else ...[
              _buildEmptyState(
                'No Currency Data',
                'Pull to refresh and load the latest currency rates',
                MdiIcons.currencyUsd,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoldTab() {
    return _buildEmptyState(
      'Gold Rates Coming Soon',
      'We\'re working on bringing you live gold prices and precious metal rates',
      MdiIcons.gold,
    );
  }

  Widget _buildCommoditiesTab() {
    return _buildEmptyState(
      'More Markets Coming Soon',
      'Additional market indicators and commodity prices will be available soon',
      MdiIcons.chartLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}