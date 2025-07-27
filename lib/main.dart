import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

void main() => runApp(PowerliftingApp());

class PowerliftingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Powerlifting Meet Tracker',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.redAccent,
          surface: Colors.grey[900]!, // Consistent background for cards/dialogs
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.redAccent),
          titleTextStyle: TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData( // Style for TextButton
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        dropdownMenuTheme: DropdownMenuThemeData( // For DropdownButton colors
          textStyle: TextStyle(color: Colors.white),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        // Text styling for better contrast
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey[300]),
          labelLarge: TextStyle(color: Colors.white),
        ).apply(
          bodyColor: Colors.white, // Default text color
          displayColor: Colors.white,
        ),
      ),
      home: HomePage(),
    );
  }
}

// Model
class Lifter {
  final String name;
  final bool onTeam;
  // IMPORTANT: These lists now hold ValueNotifier objects!
  List<ValueNotifier<double?>> squat = List.generate(3, (_) => ValueNotifier(null));
  List<ValueNotifier<bool>> squatPass = List.generate(3, (_) => ValueNotifier(false));
  List<ValueNotifier<double?>> bench = List.generate(3, (_) => ValueNotifier(null));
  List<ValueNotifier<bool>> benchPass = List.generate(3, (_) => ValueNotifier(false));
  List<ValueNotifier<double?>> deadlift = List.generate(3, (_) => ValueNotifier(null));
  List<ValueNotifier<bool>> deadPass = List.generate(3, (_) => ValueNotifier(false));

  Lifter({required this.name, required this.onTeam}) {
    // Set initial pass status for new lifters to true for the 1st attempt
    squatPass[0].value = true;
    benchPass[0].value = true;
    deadPass[0].value = true;
  }

  double best(List<ValueNotifier<double?>> w, List<ValueNotifier<bool>> p) {
    double bestWeight = 0;
    for (int i = 0; i < w.length; i++) {
      if (p[i].value && w[i].value != null && w[i].value! > bestWeight) {
        bestWeight = w[i].value!;
      }
    }
    return bestWeight;
  }

  double total() => best(squat, squatPass) + best(bench, benchPass) + best(deadlift, deadPass);
}

// Home Page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Powerlifting Tracker')),
        body: Center(
          child: ElevatedButton(
            child: Text('Start Meet'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MeetFlow()),
            ),
          ),
        ),
      );
}

// Meet Flow
class MeetFlow extends StatefulWidget {
  @override
  _MeetFlowState createState() => _MeetFlowState();
}

class _MeetFlowState extends State<MeetFlow> {
  final List<Lifter> lifters = [];
  int step = 0; // 0: Squat, 1: Bench, 2: Deadlift

  // Helper to get current lift data
  List<ValueNotifier<double?>> _getCurrentWeights(Lifter lifter) {
    switch (step) {
      case 0: return lifter.squat;
      case 1: return lifter.bench;
      case 2: return lifter.deadlift;
      default: return []; // Should not happen
    }
  }

  // Helper to get current pass status data
  List<ValueNotifier<bool>> _getCurrentPasses(Lifter lifter) {
    switch (step) {
      case 0: return lifter.squatPass;
      case 1: return lifter.benchPass;
      case 2: return lifter.deadPass;
      default: return []; // Should not happen
    }
  }

  void next() {
    // Reset bench/deadlift attempts only if moving to that specific lift
    if (step == 0) { // Moving from Squat to Bench
      for (var l in lifters) {
        for (int i = 0; i < 3; i++) {
          l.bench[i].value = null;
          l.benchPass[i].value = (i == 0); // Only first attempt can be passed by default
        }
      }
    } else if (step == 1) { // Moving from Bench to Deadlift
      for (var l in lifters) {
        for (int i = 0; i < 3; i++) {
          l.deadlift[i].value = null;
          l.deadPass[i].value = (i == 0); // Only first attempt can be passed by default
        }
      }
    }

    if (step < 2) {
      setState(() => step++);
    } else {
      showResults();
    }
  }

  void showResults() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Final Results', style: TextStyle(color: Colors.redAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: lifters
                .map((l) => Text('${l.name}: ${l.total().toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.bodyMedium))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final List<String> liftTitles = ['Squat', 'Bench Press', 'Deadlift'];

    return LiftPage(
      title: liftTitles[step],
      lifters: lifters,
      // For Squat page, only subsequent attempts are enabled. 1st squat is added via dialog.
      // For Bench/Deadlift, all attempts are editable on their respective pages.
      editableFirst: step > 0,
      onAdd: step == 0 ? addLifter : null, // Only allow adding lifters on Squat page
      onNext: next,
      getWeights: _getCurrentWeights,
      getPasses: _getCurrentPasses,
    );
  }

  void addLifter() async {
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        final nameC = TextEditingController();
        bool onTeam = false;
        double? firstSquatWeight;
        bool firstSquatPassed = true;

        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          title: Text('Add Lifter', style: TextStyle(color: Colors.redAccent)),
          content: StatefulBuilder(
            builder: (_, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(labelText: 'Lifter Name'),
                  style: Theme.of(dialogContext).textTheme.bodyLarge,
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(labelText: '1st Squat Weight (kg)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(dialogContext).textTheme.bodyLarge,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                  onChanged: (v) => firstSquatWeight = double.tryParse(v),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text('1st Squat Attempt:', style: Theme.of(dialogContext).textTheme.bodyMedium),
                    SizedBox(width: 8),
                    DropdownButton<bool>(
                      value: firstSquatPassed,
                      dropdownColor: Theme.of(dialogContext).colorScheme.surface,
                      style: Theme.of(dialogContext).textTheme.bodyLarge,
                      underline: Container(), // Remove default underline
                      items: [
                        DropdownMenuItem(value: true, child: Text('Passed ✔️')),
                        DropdownMenuItem(value: false, child: Text('Failed ✖️')),
                      ],
                      onChanged: (v) => setStateDialog(() => firstSquatPassed = v!),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text('On Team?', style: Theme.of(dialogContext).textTheme.bodyMedium),
                    SizedBox(width: 8),
                    DropdownButton<bool>(
                      value: onTeam,
                      dropdownColor: Theme.of(dialogContext).colorScheme.surface,
                      style: Theme.of(dialogContext).textTheme.bodyLarge,
                      underline: Container(),
                      items: [
                        DropdownMenuItem(value: true, child: Text('Yes')),
                        DropdownMenuItem(value: false, child: Text('No')),
                      ],
                      onChanged: (v) => setStateDialog(() => onTeam = v!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameC.text.isNotEmpty && firstSquatWeight != null) {
                  Navigator.pop(dialogContext, {
                    'name': nameC.text.trim(),
                    'squatWeight': firstSquatWeight,
                    'squatPassed': firstSquatPassed,
                    'onTeam': onTeam,
                  });
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a name and valid squat weight.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Add'),
            )
          ],
        );
      },
    );

    if (res != null) {
      setState(() {
        final newLifter = Lifter(name: res['name'], onTeam: res['onTeam']);
        newLifter.squat[0].value = res['squatWeight'];
        newLifter.squatPass[0].value = res['squatPassed'];
        lifters.add(newLifter);
      });
    }
  }
}

// Lift Page - Now Stateful to manage inputs
class LiftPage extends StatefulWidget {
  final String title;
  final List<Lifter> lifters;
  final bool editableFirst; // If true, the first attempt field is editable (for Bench/Deadlift)
  final VoidCallback? onAdd;
  final VoidCallback onNext;
  final List<ValueNotifier<double?>> Function(Lifter) getWeights;
  final List<ValueNotifier<bool>> Function(Lifter) getPasses;

  LiftPage({
    required this.title,
    required this.lifters,
    required this.editableFirst,
    this.onAdd,
    required this.onNext,
    required this.getWeights,
    required this.getPasses,
  });

  @override
  _LiftPageState createState() => _LiftPageState();
}

class _LiftPageState extends State<LiftPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.onAdd != null)
            IconButton(icon: Icon(Icons.person_add), onPressed: widget.onAdd),
          TextButton(onPressed: widget.onNext, child: Text('Next'))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.lifters.length,
              itemBuilder: (_, i) {
                final l = widget.lifters[i];
                final weights = widget.getWeights(l);
                final passes = widget.getPasses(l);

                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 2.0,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.name,
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: List.generate(3, (j) {
                            // Determine if the field should be enabled
                            bool isEnabled = (j > 0) || widget.editableFirst;
                            // For the squat's first attempt, it's only enabled via add lifter
                            // For bench/deadlift, all attempts are editable on their respective pages
                            if (widget.title == 'Squat' && j == 0) {
                              isEnabled = false; // Initial squat attempt is set during lifter add
                            }

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  children: [
                                    Text('Attempt ${j + 1}', style: Theme.of(context).textTheme.bodySmall),
                                    ValueListenableBuilder<double?>(
                                      valueListenable: weights[j],
                                      builder: (context, value, child) {
                                        final TextEditingController controller = TextEditingController(
                                          text: value?.toStringAsFixed(1) ?? '',
                                        );
                                        // Ensure the cursor is at the end when the value changes
                                        controller.selection = TextSelection.fromPosition(
                                            TextPosition(offset: controller.text.length));

                                        return TextFormField(
                                          controller: controller,
                                          enabled: isEnabled,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            filled: true,
                                            fillColor: isEnabled ? Colors.grey[850] : Colors.grey[700],
                                          ),
                                          style: Theme.of(context).textTheme.bodyLarge,
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                                          onChanged: (v) {
                                            final val = double.tryParse(v);
                                            weights[j].value = val;
                                          },
                                        );
                                      },
                                    ),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: passes[j],
                                      builder: (context, value, child) {
                                        return DropdownButtonHideUnderline(
                                          child: DropdownButton<bool>(
                                            isExpanded: true,
                                            value: value,
                                            dropdownColor: Theme.of(context).colorScheme.surface,
                                            style: Theme.of(context).textTheme.bodyLarge,
                                            items: [
                                              DropdownMenuItem(value: true, child: Center(child: Text('✔️'))),
                                              DropdownMenuItem(value: false, child: Center(child: Text('✖️'))),
                                            ],
                                            onChanged: isEnabled
                                                ? (x) {
                                                    passes[j].value = x!;
                                                  }
                                                : null, // Disable dropdown if text field is disabled
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Leaderboard is always visible at the bottom
          Leaderboard(widget.lifters),
        ],
      ),
    );
  }
}

// Leaderboard - Now uses ValueListenableBuilder for real-time updates
class Leaderboard extends StatelessWidget {
  final List<Lifter> lifters;
  Leaderboard(this.lifters);

  @override
  Widget build(BuildContext context) {
    // We create a dummy ValueNotifier that changes whenever any lifter's total changes.
    // This forces the ValueListenableBuilder to rebuild and re-sort the leaderboard.
    // For more complex apps, consider dedicated state management (Provider, Riverpod, BLoC).
    return ValueListenableBuilder<double>(
      valueListenable: lifters.isNotEmpty
          ? ValueNotifier(lifters.map((l) => l.total()).fold(0.0, (prev, curr) => prev + curr))
          : ValueNotifier(0.0), // Dummy notifier if no lifters
      builder: (context, _, child) {
        // Sort and filter every time a total changes
        final s = [...lifters]..sort((a, b) => b.total().compareTo(a.total()));
        final top3 = s.take(3).toList();
        final team = s.where((l) => l.onTeam).toList();

        return Container(
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏆 Top 3', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              if (top3.isEmpty) Text('No lifters yet!', style: Theme.of(context).textTheme.bodySmall),
              ...top3.map((l) => Text(
                  '${l.name}: ${l.total().toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.bodyMedium)),
              SizedBox(height: 12),
              Text('👥 My Team', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              if (team.isEmpty) Text('No team members yet!', style: Theme.of(context).textTheme.bodySmall),
              ...team.map((l) => Text(
                  '${l.name}: ${l.total().toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        );
      },
    );
  }
}