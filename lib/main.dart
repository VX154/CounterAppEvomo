import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int passCount = 0;
  int reworkCount = 0;
  int defectiveCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts(); // Load counts when the screen is initialized
  }

  void _loadCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      passCount = prefs.getInt('passCount') ?? 0;
      reworkCount = prefs.getInt('reworkCount') ?? 0;
      defectiveCount = prefs.getInt('defectiveCount') ?? 0;
    });
  }

  void _saveCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('passCount', passCount);
    prefs.setInt('reworkCount', reworkCount);
    prefs.setInt('defectiveCount', defectiveCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Counter'),
      ),
      body: Column(
        children: [
          _buildPieChart(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              padding: const EdgeInsets.all(10.0),
              children: [
                _buildCategoryCard('Products Passed', passCount, () {
                  setState(() {
                    passCount++;
                    _saveCounts(); // Save counts when incremented
                  });
                }),
                _buildCategoryCard('Products Reworked', reworkCount, () {
                  setState(() {
                    reworkCount++;
                    _saveCounts(); // Save counts when incremented
                  });
                }),
                _buildCategoryCard('Defective Products', defectiveCount, () {
                  setState(() {
                    defectiveCount++;
                    _saveCounts(); // Save counts when incremented
                  });
                }),
                _buildCategoryCard('Total Products', passCount + reworkCount + defectiveCount, null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          startDegreeOffset: 90,
          sections: _getSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    double total = (passCount + reworkCount + defectiveCount).toDouble();

    // Handle division by zero
    if (total == 0) {
      return [];
    }

    return List.generate(
      3,
          (index) {
        switch (index) {
          case 0:
            return PieChartSectionData(
              color: Colors.green,
              value: (passCount / total),
              title: '$passCount',
              radius: 60,
            );
          case 1:
            return PieChartSectionData(
              color: Colors.orangeAccent,
              value: (reworkCount / total),
              title: '$reworkCount',
              radius: 60,
            );
          case 2:
            return PieChartSectionData(
              color: Colors.red,
              value: (defectiveCount / total),
              title: '$defectiveCount',
              radius: 60,
            );
          default:
            throw Exception('Invalid index');
        }
      },
    );
  }


  Widget _buildCategoryCard(String category, int count, VoidCallback? onPressed) {
    Color cardColor;
    switch (category) {
      case 'Products Passed':
        cardColor = Colors.green;
        break;
      case 'Products Reworked':
        cardColor = Colors.orangeAccent;
        break;
      case 'Defective Products':
        cardColor = Colors.red;
        break;
      default:
        cardColor = Colors.blue; // Default color for Total Products
    }

    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 5.0,
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: const TextStyle(fontSize: 54.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10.0),
              Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Counter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CounterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
