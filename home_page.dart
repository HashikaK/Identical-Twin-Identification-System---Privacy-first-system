import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'search_results.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum TripType { oneWay, roundTrip, multiCity }

class _HomePageState extends State<HomePage> {
  TripType _tripType = TripType.oneWay;
  final _fromCtrl = TextEditingController(text: 'Delhi, DEL');
  final _toCtrl = TextEditingController();
  DateTime? _departure;
  DateTime? _returnDate;
  int adults = 1;
  int children = 0;
  int infants = 0;
  String travelClass = 'Economy';
  String payWith = 'Credit Card';
  final _promoCtrl = TextEditingController();

  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, {required bool isReturn}) async {
    final now = DateTime.now();
    final first = isReturn ? (_departure ?? now) : now;
    final picked = await showDatePicker(
      context: ctx,
      initialDate: first,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isReturn) {
        _returnDate = picked;
      } else {
        _departure = picked;
        if (_returnDate != null && _returnDate!.isBefore(_departure!)) {
          // auto-adjust return
          _returnDate = _departure!.add(const Duration(days: 1));
        }
      }
    });
  }

  void _openPassengerSelector() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateSB) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Passengers & Class',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              _counterRow('Adults', adults, (val) => setStateSB(() => adults = val)),
              _counterRow('Children', children, (val) => setStateSB(() => children = val)),
              _counterRow('Infants', infants, (val) => setStateSB(() => infants = val)),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Class: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: travelClass,
                  items: ['Economy', 'Premium Economy', 'Business', 'First']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setStateSB(() {
                    if (v != null) travelClass = v;
                  }),
                ),
                const Spacer(),
                ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Done'))
              ])
            ]),
          );
        });
      },
    );
  }

  Widget _counterRow(String label, int value, void Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        IconButton(
            onPressed: () => onChanged(value > 0 ? value - 1 : 0),
            icon: const Icon(Icons.remove_circle_outline)),
        Text('$value', style: const TextStyle(fontSize: 16)),
        IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline)),
      ]),
    );
  }

  void _onSearch() {
    if (_toCtrl.text.trim().isEmpty || _departure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter destination and departure date')),
      );
      return;
    }

    final params = {
      'tripType': _tripType.name,
      'from': _fromCtrl.text.trim(),
      'to': _toCtrl.text.trim(),
      'departure': _departure!.toIso8601String(),
      'return': _returnDate?.toIso8601String(),
      'adults': adults,
      'children': children,
      'infants': infants,
      'travelClass': travelClass,
      'payWith': payWith,
      'promo': _promoCtrl.text.trim(),
    };

    Navigator.of(context).pushNamed(SearchResults.routeName, arguments: params);
  }

  Widget _buildTopNav(double width) {
    final navItems = ['Book', 'Trips', 'Deals and Offers', 'Check-in', 'BluChip'];
    return Row(children: [
      Image.asset('assets/logo.jpg', height: 42),
      const SizedBox(width: 12),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: navItems
              .map((t) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(t, style: const TextStyle(color: Colors.white70)),
                  ))
              .toList(),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          onPressed: () {},
          child: const Text('Login'),
        ),
      ),
      const SizedBox(width: 8),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Elegant classic palette
    final navy = const Color(0xFF0B2545);
    final gold = const Color(0xFFB6862E);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Column(
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [navy, navy.withOpacity(0.85)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: navy.withOpacity(0.2), blurRadius: 10)],
              ),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: isMobile ? 12 : 24),
              child: SafeArea(
                child: Column(
                  children: [
                    if (!isMobile) _buildTopNav(constraints.maxWidth),
                    if (isMobile)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/logo.jpg', height: 36),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: navy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {},
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    // Heading
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Hi there, plan your journey with ease - ',
                                style: TextStyle(fontSize: isMobile ? 18 : 28, color: Colors.white70)),
                            TextSpan(
                                text: 'flights, hotels and beyond!',
                                style: TextStyle(fontSize: isMobile ? 18 : 28, color: gold, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Search Card container (centered)
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isMobile ? constraints.maxWidth - 24 : 1000),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              children: [
                                // Tabs (Flights / Hotels / Sightseeing - static)
                                Row(
                                  children: [
                                    _tabItem(Icons.flight_takeoff, 'Flights', selected: true),
                                    const SizedBox(width: 12),
                                    _tabItem(Icons.hotel, 'Hotels'),
                                    const SizedBox(width: 12),
                                    _tabItem(Icons.place, 'Sight Seeing'),
                                    const Spacer(),
                                    DropdownButton<String>(
                                      value: payWith,
                                      underline: const SizedBox(),
                                      items: ['Credit Card', 'Cash', 'UPI', 'NetBanking']
                                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                          .toList(),
                                      onChanged: (v) => setState(() => payWith = v ?? payWith),
                                    )
                                  ],
                                ),
                                const Divider(height: 20),
                                // Trip type radios
                                Row(
                                  children: [
                                    _tripRadio(TripType.oneWay, 'One Way'),
                                    _tripRadio(TripType.roundTrip, 'Round Trip'),
                                    _tripRadio(TripType.multiCity, 'Multi City'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // From / To / Dates / Travellers - responsive
                                isMobile ? _mobileForm() : _desktopForm(),
                                const SizedBox(height: 12),
                                // Promo and offers row
                                Row(
                                  children: [
                                    Wrap(spacing: 8, children: [
                                      _pill('Students'),
                                      _pill('Family & Friends'),
                                      _pill('+ ADD PROMOCODE'),
                                    ]),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: _onSearch,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: gold,
                                        foregroundColor: navy,
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Search'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // remainder placeholder (offers etc.)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(child: _offerCard('One click away', 'Find flights at lowest fare', navy)),
                      const SizedBox(width: 12),
                      Expanded(child: _offerCard('Infants fly at ₹1', 'Get ₹1750 off', navy)),
                      const SizedBox(width: 12),
                      Expanded(child: _offerCard('HDFC bank', 'Get Up to ₹5,000 Off', navy)),
                    ]),
                    const SizedBox(height: 24),
                    // Info / Footer like content
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: const Center(child: Text('More content / promotions can be shown here')),
                    ),
                    const SizedBox(height: 120)
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFF3F6FA)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _offerCard(String title, String subtitle, Color navy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [navy.withOpacity(0.06), Colors.white]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(children: [
        CircleAvatar(backgroundColor: navy, child: const Icon(Icons.arrow_upward, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ])),
      ]),
    );
  }

  Widget _tabItem(IconData icon, String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0B2545) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, color: selected ? Colors.white : Colors.white70),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70)),
      ]),
    );
  }

  Widget _tripRadio(TripType t, String label) {
    final nav = _tripType;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => setState(() => _tripType = t),
        child: Row(children: [
          Radio<TripType>(value: t, groupValue: nav, onChanged: (v) => setState(() => _tripType = v ?? nav)),
          Text(label),
        ]),
      ),
    );
  }

  Widget _desktopForm() {
    return Row(
      children: [
        Expanded(child: _inputBox('From', controller: _fromCtrl, icon: Icons.flight_takeoff)),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            final temp = _fromCtrl.text;
            setState(() {
              _fromCtrl.text = _toCtrl.text;
              _toCtrl.text = temp;
            });
          },
          icon: const Icon(Icons.swap_horiz, color: Colors.black54, size: 28),
        ),
        const SizedBox(width: 8),
        Expanded(child: _inputBox('To', controller: _toCtrl, icon: Icons.flight_land)),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDate(context, isReturn: false),
            child: _dateBox('Departure', _departure),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _tripType == TripType.roundTrip ? () => _pickDate(context, isReturn: true) : null,
            child: _dateBox('Return', _returnDate, disabled: _tripType != TripType.roundTrip),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 170,
          child: InkWell(
            onTap: _openPassengerSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Travellers + Class', style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Text('$adults Adult, $children Child · $travelClass', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        )
      ],
    );
  }

  Widget _mobileForm() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _inputBox('From', controller: _fromCtrl, icon: Icons.flight_takeoff)),
          const SizedBox(width: 8),
          Expanded(child: _inputBox('To', controller: _toCtrl, icon: Icons.flight_land)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => _pickDate(context, isReturn: false), child: _dateBox('Departure', _departure))),
          const SizedBox(width: 8),
          Expanded(child: GestureDetector(onTap: _tripType == TripType.roundTrip ? () => _pickDate(context, isReturn: true) : null, child: _dateBox('Return', _returnDate, disabled: _tripType != TripType.roundTrip))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: InkWell(onTap: _openPassengerSelector, child: _smallBox('Travellers', '$adults pax'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _promoCtrl, decoration: const InputDecoration(labelText: 'Promo code', border: OutlineInputBorder()))),
        ]),
      ],
    );
  }

  Widget _smallBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _dateBox(String label, DateTime? date, {bool disabled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: disabled ? Colors.grey.shade100 : Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(date == null ? 'Select date' : _dateFmt.format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _inputBox(String label, {required TextEditingController controller, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label, border: InputBorder.none),
          ),
        ),
      ]),
    );
  }
}
