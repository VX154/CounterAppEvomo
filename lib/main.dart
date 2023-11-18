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

  void _resetCounts() async {
    // Show a confirmation dialog
    bool confirmReset = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Reset'),
          content: Text('Are you sure you want to reset the counts?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if user confirms
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if user cancels
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    // Reset counts only if the user confirms
    if (confirmReset == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('passCount', 0);
      prefs.setInt('reworkCount', 0);
      prefs.setInt('defectiveCount', 0);

      // Update state and reload counts
      _loadCounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Counter'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPieChart(),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              padding: const EdgeInsets.all(10.0),
              shrinkWrap: true,
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
            ElevatedButton(
              onPressed: _resetCounts,
              child: Text('Reset Counts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double pieChartSize = constraints.maxWidth > 600 ? 400.0 : constraints.maxWidth * 0.8;
        return AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: pieChartSize * 0.2,
              startDegreeOffset: 90,
              sections: _getSections(),
            ),
          ),
        );
      },
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
