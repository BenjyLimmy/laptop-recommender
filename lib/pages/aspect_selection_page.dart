import 'package:flutter/material.dart';
import 'package:laptop_reco/models/preferences_model.dart';
import 'package:laptop_reco/pages/results_page.dart';
import 'package:laptop_reco/widgets/aspect_selection_tile.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class AspectSelectionPage extends StatefulWidget {
  @override
  State<AspectSelectionPage> createState() => _AspectSelectionPageState();
}

class _AspectSelectionPageState extends State<AspectSelectionPage>
    with SingleTickerProviderStateMixin {
  final int maxSelections = 4;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    // Make sure to dispose the controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesModel>(context);
    final selectedCount =
        prefs.aspectSelected.values.where((v) => v == true).length;
    final colorScheme = Theme.of(context).colorScheme;

    // Get selected aspects for display
    var selectedAspects = PreferencesModel.aspects
        .where((aspect) => prefs.aspectSelected[aspect] == true)
        .toList()
      ..sort((a, b) =>
          (prefs.aspectWeights[b] ?? 0).compareTo(prefs.aspectWeights[a] ?? 0));

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Customize Your Preferences',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   forceMaterialTransparency: true,
      // ),
      body: Column(
        children: [
          // Top section with instruction cards
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 100),
                  Text(
                    'What matters most to you in a laptop?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    child: Lottie.asset(
                      'assets/animations/laptop.json',
                      controller: _controller,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ],
              ),
              Text(
                'Select up to $maxSelections aspects and set their importance',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              // Selection progress indicator
              Row(
                // alignment: Alignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 10),
                      child: LinearProgressIndicator(
                        value: selectedCount / maxSelections,
                        backgroundColor: Colors.grey[300],
                        color: selectedCount == maxSelections
                            ? Colors.green
                            : colorScheme.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: selectedCount == maxSelections
                            ? Colors.green
                            : Colors.purple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$selectedCount/$maxSelections selected',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Aspect selection list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3,
                ),
                itemCount: PreferencesModel.aspects.length,
                itemBuilder: (context, index) {
                  final aspect = PreferencesModel.aspects[index];
                  bool isSelected = prefs.aspectSelected[aspect] ?? false;
                  double weight = prefs.aspectWeights[aspect] ?? 5.0;

                  return AspectSelectionTile(
                    aspect: aspect,
                    isSelected: isSelected,
                    weight: weight,
                    onSelectedChanged: (selectedCount >= maxSelections &&
                            !isSelected)
                        ? null // Disable if max reached and not already selected
                        : (value) =>
                            prefs.setAspectSelected(aspect, value ?? false),
                    onWeightChanged: isSelected
                        ? (value) => prefs.setAspectWeight(aspect, value)
                        : null,
                  );
                },
              ),
            ),
          ),

          // Bottom action area with selected chips and button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selected aspects with drag indicator
                if (selectedCount > 0) ...[
                  Container(
                    height: 56,
                    child: selectedCount > 0
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedAspects.length,
                            itemBuilder: (context, index) {
                              final aspect = selectedAspects[index];
                              final weight = prefs.aspectWeights[aspect] ?? 5.0;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(aspect),
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  deleteIcon: Icon(Icons.cancel, size: 18),
                                  onDeleted: () =>
                                      prefs.setAspectSelected(aspect, false),
                                  avatar: CircleAvatar(
                                    backgroundColor:
                                        _getImportanceColor(weight),
                                    child: Text(
                                      weight.round().toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    radius: 12,
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: _getImportanceColor(weight),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No aspects selected yet',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 16),
                ],

                // Action button
                ElevatedButton.icon(
                  icon: Icon(Icons.search),
                  label: Text('FIND MY PERFECT LAPTOP'),
                  onPressed: selectedCount > 0
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ResultsPage()),
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get color based on importance
  Color _getImportanceColor(double weight) {
    if (weight >= 8) return Colors.red;
    if (weight >= 6) return Colors.orange;
    if (weight >= 4) return Colors.blue;
    return Colors.grey;
  }
}
