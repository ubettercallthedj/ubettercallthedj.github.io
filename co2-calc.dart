import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// DATA_MODEL
/// Manages the state and calculations for the carbon footprint.
class HuellaCarbonoData extends ChangeNotifier {
  // Input values
  double _viviendaKwhMes;
  double _autoKmAnuales;
  String _combustible;
  int _vuelosEuropa;
  double _kgCarneSemana;

  // Calculation results
  double vivienda = 0;
  double transporte = 0;
  double alimentacion = 0;
  double vuelos = 0;
  double totalAnual = 0;
  double arbolesNecesarios = 0;

  bool _calculado = false; // Indicates if an initial calculation has occurred

  HuellaCarbonoData({
    double viviendaKwhMes = 150,
    double autoKmAnuales = 12000,
    String combustible = "Bencina",
    int vuelosEuropa = 1,
    double kgCarneSemana = 7,
  })  : _viviendaKwhMes = viviendaKwhMes,
        _autoKmAnuales = autoKmAnuales,
        _combustible = combustible,
        _vuelosEuropa = vuelosEuropa,
        _kgCarneSemana = kgCarneSemana {
    _calcular(); // Perform initial calculation
  }

  // Getters for input values
  double get viviendaKwhMes => _viviendaKwhMes;
  double get autoKmAnuales => _autoKmAnuales;
  String get combustible => _combustible;
  int get vuelosEuropa => _vuelosEuropa;
  double get kgCarneSemana => _kgCarneSemana;
  bool get calculado => _calculado;

  // Setters for input values that trigger recalculation and UI update
  set viviendaKwhMes(double value) {
    if (_viviendaKwhMes != value) {
      _viviendaKwhMes = value;
      _calcular();
    }
  }

  set autoKmAnuales(double value) {
    if (_autoKmAnuales != value) {
      _autoKmAnuales = value;
      _calcular();
    }
  }

  set combustible(String value) {
    if (_combustible != value) {
      _combustible = value;
      _calcular();
    }
  }

  set vuelosEuropa(int value) {
    if (_vuelosEuropa != value) {
      _vuelosEuropa = value;
      _calcular();
    }
  }

  set kgCarneSemana(double value) {
    if (_kgCarneSemana != value) {
      _kgCarneSemana = value;
      _calcular();
    }
  }

  /// Calculates the carbon footprint based on current input values.
  void _calcular() {
    // Factores de emisión 2025 (promedios Chile/LATAM + globales)
    vivienda =
        (_viviendaKwhMes * 0.45) *
        12 /
        1000; // 0.45 kg CO₂e por kWh (mix chileno)

    // Transporte
    double factorCombustible;
    if (_combustible == "Bencina") {
      factorCombustible = 2.3; // kg CO₂e/litro
    } else if (_combustible == "Diesel") {
      factorCombustible = 2.7; // kg CO₂e/litro
    } else {
      factorCombustible =
          0.0; // Eléctrico (asume 0 emisiones directas del auto)
    }
    final double consumoLitros =
        _autoKmAnuales / 10; // aprox 10 km/litro promedio
    transporte = (consumoLitros * factorCombustible) / 1000;

    // Alimentación (carne roja es el mayor impacto)
    alimentacion =
        (_kgCarneSemana * 52 * 50) / 1000; // 50 kg CO₂e por kg de carne roja

    // Vuelos (ida y vuelta SCL-Europa ≈ 8.5 t CO₂e por persona)
    vuelos = _vuelosEuropa * 8.5;

    totalAnual = vivienda + transporte + alimentacion + vuelos;
    arbolesNecesarios =
        totalAnual / 0.021; // 21 kg CO₂ absorbido por árbol adulto/año

    _calculado = true;
    notifyListeners(); // Notify listeners of changes
  }
}

/// DATA_MODEL
/// Manages the current theme mode of the application.
class ThemeModeData extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Start with system default

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}

void main() => runApp(
      MultiProvider(
        providers: <ChangeNotifierProvider<ChangeNotifier>>[
          ChangeNotifierProvider<HuellaCarbonoData>(
            create: (BuildContext context) => HuellaCarbonoData(),
          ),
          ChangeNotifierProvider<ThemeModeData>(
            create: (BuildContext context) => ThemeModeData(),
          ),
        ],
        builder: (BuildContext context, Widget? child) => const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Neon Color Palette
  static const Color _neonPurple = Color(0xFFD200FF); // Electric Violet
  static const Color _neonCyan = Color(0xFF00FFFF); // Electric Cyan
  // static const Color _neonPink = Color(0xFFFF00CC); // Electric Pink (for prominent elements) - not currently used

  // Theme specific colors
  static const Color _darkBackground = Color(0xFF120024); // Very dark purple
  static const Color _darkSurface = Color(
    0xFF2C0054,
  ); // Slightly lighter for cards/surfaces
  static const Color _neonTextOnDark = Color(
    0xFFE0FFFF,
  ); // Near white neon cyan for text
  static const Color _neonHintOnDark = Color(
    0xFF8B008B,
  ); // Darker purple for hints

  static const Color _lightBackground = Color(0xFFF0E6FA); // Pale lavender
  static const Color _lightSurface = Color(0xFFF8F0FC); // Even paler for cards
  static const Color _neonTextOnLight = Color(
    0xFF4B0082,
  ); // Darker purple for text
  static const Color _neonHintOnLight = Color(
    0xFF9400D3,
  ); // Medium purple for hints

  // Status colors for results
  static const Color _neonRedStatus = Color(
    0xFFFF073A,
  ); // Electric Red for bad status
  static const Color _neonGreenStatus = Color(
    0xFF39FF14,
  ); // Electric Green for good status

  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = Provider.of<ThemeModeData>(context).themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dejando Huella',
      themeMode: themeMode, // Use the state-managed theme mode
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: _neonPurple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _neonPurple,
          primary: _neonPurple,
          secondary: _neonCyan,
          onPrimary: _neonCyan, // Text on primary buttons
          surface: _lightSurface,
          onSurface: _neonTextOnLight, // Text on general surfaces
        ),
        scaffoldBackgroundColor: _lightBackground,
        cardColor: _lightSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: _lightSurface, // Lighter background for app bar
          foregroundColor:
              _neonPurple, // Use neon purple for app bar icons/text
          titleTextStyle: TextStyle(
            color: _neonPurple, // Title text in neon purple
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _neonPurple,
            foregroundColor: _neonCyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shadowColor: _neonCyan.withAlpha(
              128,
            ), // Changed from withOpacity(0.5) to withAlpha(128)
            elevation: 8, // More pronounced shadow
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              color: _neonHintOnLight,
              width: 1,
            ), // Muted neon border
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: _neonHintOnLight, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              color: _neonCyan,
              width: 2,
            ), // Bright neon on focus for 3D glow
          ),
          labelStyle: const TextStyle(color: _neonPurple),
          hintStyle: const TextStyle(color: _neonHintOnLight),
          suffixStyle: const TextStyle(color: _neonTextOnLight),
          filled: true,
          fillColor:
              _lightSurface, // Slightly different color for the fill to create depth
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: _neonPurple, // Default icon color for light theme
          titleTextStyle: TextStyle(color: _neonTextOnLight),
          subtitleTextStyle: TextStyle(color: _neonHintOnLight),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: _neonTextOnLight.withAlpha(230),
          ), // Changed from withOpacity(0.9) to withAlpha(230)
          bodyMedium: TextStyle(
            color: _neonTextOnLight.withAlpha(204),
          ), // Changed from withOpacity(0.8) to withAlpha(204)
          bodySmall: TextStyle(
            color: _neonTextOnLight.withAlpha(179),
          ), // Changed from withOpacity(0.7) to withAlpha(179)
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: _neonPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: _darkBackground,
        cardColor: _darkSurface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _neonPurple,
          brightness: Brightness.dark,
          primary: _neonPurple,
          onPrimary: _neonCyan, // Text on primary buttons
          secondary: _neonCyan,
          surface:
              _darkSurface, // Slightly lighter than background for elevated surfaces
          onSurface: _neonTextOnDark, // Text on surface
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _darkBackground, // Darker background for app bar
          foregroundColor: _neonCyan,
          titleTextStyle: const TextStyle(
            color: _neonCyan,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _neonPurple,
            foregroundColor: _neonCyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shadowColor: _neonCyan.withAlpha(
              128,
            ), // Changed from withOpacity(0.5) to withAlpha(128)
            elevation: 8,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              color: _neonHintOnDark,
              width: 1,
            ), // Muted neon border
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: _neonHintOnDark, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              color: _neonCyan,
              width: 2,
            ), // Bright neon on focus for 3D glow
          ),
          labelStyle: const TextStyle(color: _neonCyan), // Lighter label
          hintStyle: const TextStyle(color: _neonHintOnDark),
          suffixStyle: const TextStyle(color: _neonTextOnDark),
          filled: true,
          fillColor:
              _darkBackground, // Slightly different color for the fill to create depth
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: _neonTextOnDark.withAlpha(230),
          ), // Changed from withOpacity(0.9) to withAlpha(230)
          bodyMedium: TextStyle(
            color: _neonTextOnDark.withAlpha(204),
          ), // Changed from withOpacity(0.8) to withAlpha(204)
          bodySmall: TextStyle(
            color: _neonTextOnDark.withAlpha(179),
          ), // Changed from withOpacity(0.7) to withAlpha(179)
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: _neonCyan, // Accent green for icons in dark theme
          titleTextStyle: TextStyle(color: _neonTextOnDark),
          subtitleTextStyle: TextStyle(color: _neonHintOnDark),
        ),
      ),
      home: const HuellaCarbonoScreen(),
    );
  }
}

class HuellaCarbonoScreen extends StatelessWidget {
  const HuellaCarbonoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch for changes in HuellaCarbonoData
    final HuellaCarbonoData data = Provider.of<HuellaCarbonoData>(context);
    // Listen to ThemeModeData to update the icon based on the theme
    final ThemeModeData themeData = Provider.of<ThemeModeData>(
      context,
      listen: false,
    );
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Helper functions to get conditional colors based on theme and data for neon status
    Color _getCardTitleColor() {
      return isDarkMode ? MyApp._neonCyan : MyApp._neonPurple;
    }

    Color _getCardMessageColor(double totalAnual) {
      if (totalAnual > 6) {
        return isDarkMode
            ? MyApp._neonRedStatus
            : MyApp._neonRedStatus.withAlpha(
                230,
              ); // Changed from withOpacity(0.9) to withAlpha(230)
      } else {
        return isDarkMode
            ? MyApp._neonGreenStatus
            : MyApp._neonGreenStatus.withAlpha(
                230,
              ); // Changed from withOpacity(0.9) to withAlpha(230)
      }
    }

    Color _getInputBorderColor() {
      return isDarkMode ? MyApp._neonHintOnDark : MyApp._neonHintOnLight;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.eco_outlined,
          size: 30,
        ), // Added CO2/carbon footprint icon
        title: const Text("Dejando Huella", textAlign: TextAlign.center),
        toolbarHeight: 70, // Give more space for the two-line title
        actions: <Widget>[
          IconButton(
            icon: Icon(
              isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode, // Icon changes based on current theme
              color: Theme.of(
                context,
              ).appBarTheme.foregroundColor, // Use AppBar foreground color
            ),
            onPressed: () {
              themeData.toggleTheme();
              HapticFeedback.lightImpact(); // Provide haptic feedback on toggle
            },
          ),
          const SizedBox(width: 8), // Padding on the right
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            // === INPUTS ===
            _HuellaCarbonoInputField(
              initialValue: data.viviendaKwhMes.toString(),
              label: "Consumo eléctrico + gas",
              suffix: "kWh/mes",
              hint: "Ej: 150",
              keyboardType: TextInputType.number,
              onChanged: (String value) => data.viviendaKwhMes =
                  double.tryParse(value) ?? data.viviendaKwhMes,
            ),
            const SizedBox(height: 16),
            _HuellaCarbonoInputField(
              initialValue: data.autoKmAnuales.toString(),
              label: "Kilómetros en auto al año",
              suffix: "km",
              hint: "Ej: 12000",
              keyboardType: TextInputType.number,
              onChanged: (String value) => data.autoKmAnuales =
                  double.tryParse(value) ?? data.autoKmAnuales,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: data.combustible,
              decoration: const InputDecoration(
                labelText: "Combustible del auto",
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: "Bencina",
                  child: Text("Bencina"),
                ),
                DropdownMenuItem<String>(
                  value: "Diesel",
                  child: Text("Diesel"),
                ),
                DropdownMenuItem<String>(
                  value: "Eléctrico",
                  child: Text("Eléctrico (0 emisiones)"),
                ),
              ],
              onChanged: (String? v) {
                if (v != null) {
                  data.combustible = v;
                }
              },
            ),
            const SizedBox(height: 16),
            _HuellaCarbonoInputField(
              initialValue: data.vuelosEuropa.toString(),
              label: "Viajes a Europa/USA al año",
              suffix: "",
              hint: "Ej: 0, 1, 2",
              keyboardType: TextInputType.number,
              onChanged: (String value) =>
                  data.vuelosEuropa = int.tryParse(value) ?? data.vuelosEuropa,
            ),
            const SizedBox(height: 16),
            _HuellaCarbonoInputField(
              initialValue: data.kgCarneSemana.toString(),
              label: "Kg de carne por semana",
              suffix: "kg",
              hint: "Ej: 0–10",
              keyboardType: TextInputType.number,
              onChanged: (String value) => data.kgCarneSemana =
                  double.tryParse(value) ?? data.kgCarneSemana,
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  // Calculation happens automatically on input change, this button is purely for feedback.
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface, // Use onSurface for text
                  side: BorderSide(
                    color: _getInputBorderColor(),
                    width: 2,
                  ), // Doubled width from 1 to 2
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("CALCULAR MI HUELLA"),
              ),
            ),
            const SizedBox(height: 32),

            // === RESULTADO ===
            if (data.calculado) ...<Widget>[
              // Main result card
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "TU HUELLA ANUAL",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ), // Dynamic primary color
                      const SizedBox(height: 12),
                      Text(
                        "${data.totalAnual.toStringAsFixed(1)} toneladas CO₂",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getCardTitleColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Equivale a ${data.arbolesNecesarios.toStringAsFixed(0)} árboles para compensar",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data.totalAnual > 6
                            ? "¡Muy por encima del promedio mundial!"
                            : data.totalAnual > 3
                                ? "Estás por encima del objetivo 2030"
                                : "¡Excelente! Vas camino a la neutralidad",
                        style: TextStyle(
                          fontSize: 16,
                          color: _getCardMessageColor(data.totalAnual),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Breakdown of results
              _DesgloseRow(
                titulo: "Vivienda (luz + gas)",
                toneladas: data.vivienda,
                icon: Icons.home,
              ),
              _DesgloseRow(
                titulo: "Transporte",
                toneladas: data.transporte,
                icon: Icons.directions_car,
              ),
              _DesgloseRow(
                titulo: "Alimentación (carne roja)",
                toneladas: data.alimentacion,
                icon: Icons.set_meal,
              ),
              _DesgloseRow(
                titulo: "Vuelos",
                toneladas: data.vuelos,
                icon: Icons.flight,
              ),

              const SizedBox(height: 32),
              OutlinedButton.icon(
                icon: Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                label: Text(
                  "Ver plan de reducción personalizado",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Próximamente: plan semanal para bajar 60 %",
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary, // Use theme's primary color
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A custom text input field for numeric values in the carbon footprint calculator.
class _HuellaCarbonoInputField extends StatefulWidget {
  final String initialValue;
  final String label;
  final String suffix;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _HuellaCarbonoInputField({
    required this.initialValue,
    required this.label,
    required this.suffix,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
  });

  @override
  State<_HuellaCarbonoInputField> createState() =>
      _HuellaCarbonoInputFieldState();
}

class _HuellaCarbonoInputFieldState extends State<_HuellaCarbonoInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _HuellaCarbonoInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller's text if the initialValue from parent changes
    // Only update if the current text is different, to avoid infinite loops and unnecessary updates.
    if (widget.initialValue != oldWidget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
      // Ensure onChanged is called if the text is programmatically updated
      // This is important if initialValue updates from provider and the field needs to reflect that
      // No need to explicitly call onChanged here as _onTextChanged will be triggered by text controller's change.
    }
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9.]'),
        ), // Allow digits and decimal point
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixText: widget.suffix,
      ),
    );
  }
}

/// A widget to display a single row of carbon footprint breakdown.
class _DesgloseRow extends StatelessWidget {
  final String titulo;
  final double toneladas;
  final IconData icon;

  const _DesgloseRow({
    required this.titulo,
    required this.toneladas,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ), // Dynamic primary color for icon
        title: Text(titulo),
        trailing: Text(
          "${toneladas.toStringAsFixed(1)} t",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ), // Changed text color to Theme.of(context).primaryColor (which is _neonPurple)
        ),
      ),
    );
  }
}
