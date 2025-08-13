import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'package:financial_literacy_frontend/widgets/card.dart';
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
  String get formattedSelling => 'Rs ${selling.toStringAsFixed(2)}';
}

class EconomicIndicators extends StatefulWidget {
  final List<Map<String, dynamic>> economicData;
  final bool isLoading;
  final String? error;

  const EconomicIndicators({
    super.key,
    required this.economicData,
    required this.isLoading,
    required this.error,
  });

  @override
  State<EconomicIndicators> createState() => _EconomicIndicatorsState();
}

class _EconomicIndicatorsState extends State<EconomicIndicators> {
  List<CurrencyData> currencyData = [];
  bool isLoadingCurrencies = false;
  String? currencyError;
  Timer? _refreshTimer;

  static const List<String> priorityCurrencies = [
    'USD', 'EUR', 'GBP', 'AUD', 'CAD', 'JPY', 'CHF', 'CNY'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrencyData();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _fetchCurrencyData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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
      ).timeout(const Duration(seconds: 10));

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
            return a.currency.compareTo(b.currency);
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
          currencyError = 'Failed to load currency rates';
          isLoadingCurrencies = false;
        });
      }
    }
  }

  Widget _buildCompactCurrencyItem(CurrencyData currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              currency.displayCurrency,
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currency.formattedTTRate,
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  fontSize: 13,
                ),
              ),
              Text(
                'Buy Rate',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStockItem(Map<String, dynamic> stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              stock['symbol'],
              style: AppTypography.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stock['value'],
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  fontSize: 13,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    stock['positive'] ? MdiIcons.trendingUp : MdiIcons.trendingDown,
                    size: 10,
                    color: stock['positive'] ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    stock['change'],
                    style: AppTypography.caption.copyWith(
                      color: stock['positive'] ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MdiIcons.alertCircleOutline, color: AppColors.error, size: 20),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              minimumSize: const Size(0, 32),
            ),
            child: Text(
              'Retry',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasStockData = widget.economicData.isNotEmpty && !widget.isLoading;
    final hasCurrencyData = currencyData.isNotEmpty && !isLoadingCurrencies;
    final isAnyLoading = widget.isLoading || isLoadingCurrencies;

    return AppCard(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(MdiIcons.finance, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Market Overview',
                    style: AppTypography.h4.copyWith(color: AppColors.primary),
                  ),
                ),
                if (isAnyLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withOpacity(0.6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            if (isAnyLoading && !hasStockData && !hasCurrencyData)
              const Padding(
                padding: EdgeInsets.all(20),
                child: LoadingSpinner(),
              )
            else if (widget.error != null && currencyError != null)
              _buildErrorState('Unable to load market data', () {
                _fetchCurrencyData();
              })
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Currency Rates Section
                      if (hasCurrencyData) ...[
                        Row(
                          children: [
                            Icon(MdiIcons.currencyUsd, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Currency Rates (MUR)',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              currencyData.first.transactionDate,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (currencyData.length > 4) ? 4 : currencyData.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) => _buildCompactCurrencyItem(currencyData[index]),
                        ),
                      ],

                      // Separator
                      if (hasStockData && hasCurrencyData) ...[
                        const SizedBox(height: 16),
                        Divider(color: AppColors.border.withOpacity(0.3), height: 1),
                        const SizedBox(height: 16),
                      ],

                      // Stock Market Section
                      if (hasStockData) ...[
                        Row(
                          children: [
                            Icon(MdiIcons.chartLine, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Global Markets',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.economicData.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) => _buildCompactStockItem(widget.economicData[index]),
                        ),
                      ],

                      // Currency error state (when stocks loaded but currencies failed)
                      if (hasStockData && currencyError != null && !hasCurrencyData) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(MdiIcons.currencyUsd, size: 16, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Currency rates temporarily unavailable',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.warning,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _fetchCurrencyData,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: const Size(0, 28),
                                ),
                                child: Text(
                                  'Retry',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
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
              ),
          ],
        ),
      ),
    );
  }
}