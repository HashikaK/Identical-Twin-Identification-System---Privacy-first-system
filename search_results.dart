import 'package:flutter/material.dart';
import 'dart:math';

class SearchResults extends StatelessWidget {
  static const routeName = '/results';
  const SearchResults({super.key});

  List<Map<String, dynamic>> _generateResults(Map args) {
    // create a few mock results derived from input for realism
    final rand = Random(args.hashCode);
    final basePrice = 2500 + (rand.nextInt(8) * 300); // base
    final List<String> carriers = ['ClassicAir', 'AeroLux', 'SkyLine', 'SunWings', 'Nimbus'];
    final departure = DateTime.parse(args['departure']);
    final returnStr = args['return'];
    final List<Map<String, dynamic>> results = List.generate(6, (i) {
      final carrier = carriers[rand.nextInt(carriers.length)];
      final depOffsetHours = 6 + rand.nextInt(12);
      final durHours = 2 + rand.nextInt(6);
      final price = basePrice + rand.nextInt(2000) - i * 150;
      final depTime = departure.add(Duration(hours: depOffsetHours + i));
      return {
        'carrier': carrier,
        'from': args['from'],
        'to': args['to'],
        'departTime': depTime,
        'duration': '${durHours}h ${rand.nextInt(60).toString().padLeft(2, '0')}m',
        'price': price,
        'stops': rand.nextBool() ? 'Non-stop' : '${1 + rand.nextInt(2)} stop(s)',
      };
    });
    // sort by price ascending
    results.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map? ?? {};
    final results = _generateResults(args);
    final title = args.isNotEmpty ? '${args['from']} → ${args['to']}' : 'Search Results';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B2545),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          // Summary card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(children: [
                Expanded(child: Text('From: ${args['from'] ?? '—'}')),
                Expanded(child: Text('To: ${args['to'] ?? '—'}')),
                Expanded(child: Text('Depart: ${args.isNotEmpty ? DateTime.parse(args['departure']).toLocal().toString().split(' ')[0] : '—'}')),
                ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Edit'))
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, idx) {
                final r = results[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0B2545),
                      child: Text(r['carrier'][0], style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text('${r['carrier']} — ${r['from'].split(',').first} → ${r['to'].split(',').first}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 6),
                      Text('Departs: ${r['departTime'].toLocal().toString().substring(11,16)} • ${r['duration']} • ${r['stops']}'),
                    ]),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('₹${r['price']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: () {
                        _showBookingDialog(context, r);
                      }, child: const Text('Book'))
                    ]),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  void _showBookingDialog(BuildContext ctx, Map flight) {
    showDialog(
        context: ctx,
        builder: (dctx) {
          return AlertDialog(
            title: Text('Confirm Booking - ${flight['carrier']}'),
            content: Text('Price: ₹${flight['price']}\nDuration: ${flight['duration']}\nProceed to book?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Cancel')),
              ElevatedButton(onPressed: () {
                Navigator.of(dctx).pop();
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Booking completed (mock).')));
              }, child: const Text('Confirm'))
            ],
          );
        });
  }
}
