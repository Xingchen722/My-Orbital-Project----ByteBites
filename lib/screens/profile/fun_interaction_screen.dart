import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class FunInteractionScreen extends StatefulWidget {
  const FunInteractionScreen({super.key});

  @override
  State<FunInteractionScreen> createState() => _FunInteractionScreenState();
}

class _FunInteractionScreenState extends State<FunInteractionScreen>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late AnimationController _diceController;
  late Animation<double> _wheelAnimation;
  late Animation<double> _diceAnimation;
  
  double _wheelAngle = 0.0;
  int _diceNumber = 1;
  bool _isSpinning = false;
  bool _isRolling = false;
  
  String _selectedMode = 'wheel'; // 'wheel' or 'dice'
  String _selectedType = 'custom'; // 'custom' or 'default'
  
  List<String> _customFoods = [];
  List<String> _defaultFoods = [
    'Chicken Rice',
    'Nasi Lemak',
    'Laksa',
    'Char Kway Teow',
    'Hainanese Chicken',
    'Bak Kut Teh',
    'Satay',
    'Roti Prata',
    'Mee Goreng',
    'Fish Head Curry',
    'Chilli Crab',
    'Kaya Toast',
    'Ice Kacang',
    'Chendol',
    'Durian',
  ];
  
  List<String> _defaultRestaurants = [
    'The Summit',
    'Frontier',
    'Techno Edge',
    'PGP',
    'The Deck',
    'The Terrace',
    'Yusof Ishak House',
    'Fine Food',
  ];

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _wheelAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutCubic,
    ));
    
    _diceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _diceController,
      curve: Curves.easeOutBack,
    ));
    
    _loadCustomFoods();
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _diceController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUsername') ?? '';
    final customFoods = prefs.getStringList('custom_foods_$username') ?? [];
    setState(() {
      _customFoods = customFoods;
    });
  }

  Future<void> _saveCustomFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUsername') ?? '';
    await prefs.setStringList('custom_foods_$username', _customFoods);
  }

  void _spinWheel() {
    if (_isSpinning) return;
    
    setState(() {
      _isSpinning = true;
    });
    
    final random = Random();
    final spins = 5 + random.nextInt(5); // 5-10 spins
    final finalAngle = random.nextDouble() * 360;
    
    _wheelAnimation = Tween<double>(
      begin: _wheelAngle,
      end: _wheelAngle + (360 * spins) + finalAngle,
    ).animate(CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutCubic,
    ));
    
    _wheelController.forward().then((_) {
      setState(() {
        _wheelAngle = (_wheelAngle + (360 * spins) + finalAngle) % 360;
        _isSpinning = false;
      });
      
      _showResult();
    });
  }

  void _rollDice() {
    if (_isRolling) return;
    
    setState(() {
      _isRolling = true;
    });
    
    final random = Random();
    final rolls = 3 + random.nextInt(3); // 3-6 rolls
    final finalNumber = 1 + random.nextInt(6);
    
    _diceController.forward().then((_) {
      setState(() {
        _diceNumber = finalNumber;
        _isRolling = false;
      });
      
      _showResult();
    });
  }

  void _showResult() {
    final l10n = AppLocalizations.of(context)!;
    String result = '';
    
    if (_selectedMode == 'wheel') {
      final items = _selectedType == 'custom' ? _customFoods : _defaultFoods;
      if (items.isNotEmpty) {
        final random = Random();
        result = items[random.nextInt(items.length)];
      }
    } else {
      final items = _selectedType == 'custom' ? _customFoods : _defaultRestaurants;
      if (items.isNotEmpty) {
        final random = Random();
        result = items[random.nextInt(items.length)];
      }
    }
    
    if (result.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.result),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    }
  }

  void _addCustomFood() {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addCustomFood),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.enterFoodName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _customFoods.add(controller.text.trim());
                });
                _saveCustomFoods();
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.funInteraction),
        backgroundColor: const Color(0xFF16a951),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 模式选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectMode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.wheel),
                            selected: _selectedMode == 'wheel',
                            onSelected: (selected) {
                              setState(() {
                                _selectedMode = 'wheel';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.dice),
                            selected: _selectedMode == 'dice',
                            onSelected: (selected) {
                              setState(() {
                                _selectedMode = 'dice';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 类型选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.custom),
                            selected: _selectedType == 'custom',
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = 'custom';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.defaultOption),
                            selected: _selectedType == 'default',
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = 'default';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 自定义食物管理
            if (_selectedType == 'custom') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.customFoods,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addCustomFood,
                            icon: const Icon(Icons.add),
                            label: Text(l10n.add),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16a951),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_customFoods.isEmpty)
                        Text(
                          l10n.noCustomFoods,
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _customFoods.map((food) {
                            return Chip(
                              label: Text(food),
                              onDeleted: () {
                                setState(() {
                                  _customFoods.remove(food);
                                });
                                _saveCustomFoods();
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // 转盘或骰子显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_selectedMode == 'wheel') ...[
                      SizedBox(
                        height: 200,
                        child: AnimatedBuilder(
                          animation: _wheelAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _wheelAnimation.value * 2 * pi / 180,
                              child: CustomPaint(
                                size: const Size(200, 200),
                                painter: WheelPainter(
                                  items: _selectedType == 'custom' 
                                      ? _customFoods 
                                      : _defaultFoods,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSpinning ? null : _spinWheel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16a951),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          _isSpinning ? l10n.spinning : l10n.spinWheel,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _diceAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_diceAnimation.value * 0.2),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$_diceNumber',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16a951),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isRolling ? null : _rollDice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16a951),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          _isRolling ? l10n.rolling : l10n.rollDice,
                          style: const TextStyle(color: Colors.white),
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

class WheelPainter extends CustomPainter {
  final List<String> items;
  
  WheelPainter({required this.items});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) {
      // 绘制空转盘
      final paint = Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2 - 10,
        paint,
      );
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'No items',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2,
        ),
      );
      return;
    }
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final anglePerItem = 2 * pi / items.length;
    
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
    ];
    
    for (int i = 0; i < items.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      
      final startAngle = i * anglePerItem;
      final endAngle = (i + 1) * anglePerItem;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
        paint,
      );
      
      // 绘制文字
      final textAngle = startAngle + anglePerItem / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i].length > 8 ? '${items[i].substring(0, 8)}...' : items[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
    
    // 绘制中心点
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerPaint);
    
    // 绘制指针
    final pointerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(center.dx, center.dy - radius + 5);
    path.lineTo(center.dx - 8, center.dy - radius - 10);
    path.lineTo(center.dx + 8, center.dy - radius - 10);
    path.close();
    
    canvas.drawPath(path, pointerPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 