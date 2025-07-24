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

  // 1. 聊天室相关状态
  List<Map<String, String>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  bool _showChatRoom = false;

  Future<void> _loadChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('fun_chat_messages') ?? [];
    setState(() {
      _chatMessages = list.map((e) {
        final parts = e.split('|:|');
        return {'user': parts[0], 'msg': parts[1]};
      }).toList();
    });
  }

  Future<void> _saveChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _chatMessages.map((e) => '${e['user']}|:|${e['msg']}').toList();
    await prefs.setStringList('fun_chat_messages', list);
  }

  // 猜数字小游戏相关状态
  bool _showGuessNumber = false;
  int _targetNumber = 0;
  int _guessCount = 0;
  String _guessFeedback = '';
  final TextEditingController _guessController = TextEditingController();

  void _startGuessNumberGame() {
    setState(() {
      _targetNumber = 1 + Random().nextInt(100);
      _guessCount = 0;
      _guessFeedback = '';
      _guessController.clear();
      _showGuessNumber = true;
    });
  }

  void _submitGuess(String lang) {
    final guess = int.tryParse(_guessController.text.trim());
    if (guess == null) {
      setState(() {
        _guessFeedback = lang == 'zh' ? '请输入有效数字' : 'Please enter a valid number';
      });
      return;
    }
    setState(() {
      _guessCount++;
      if (guess == _targetNumber) {
        _guessFeedback = lang == 'zh'
          ? '恭喜你，猜对了！总共猜了 $_guessCount 次'
          : 'Congratulations! You guessed it in $_guessCount tries!';
        _updateLeaderboard(_guessCount);
      } else if (guess < _targetNumber) {
        _guessFeedback = lang == 'zh' ? '太小了，再试试~' : 'Too low, try again!';
      } else {
        _guessFeedback = lang == 'zh' ? '太大了，再试试~' : 'Too high, try again!';
      }
    });
    _guessController.clear();
  }

  // 排行榜相关状态
  bool _showLeaderboard = false;
  int _bestGuessCount = 0;
  String _bestGuessUser = '';

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestGuessCount = prefs.getInt('fun_best_guess_count') ?? 0;
      _bestGuessUser = prefs.getString('fun_best_guess_user') ?? '';
    });
  }

  Future<void> _updateLeaderboard(int guessCount) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUsername') ?? (Localizations.localeOf(context).languageCode == 'zh' ? '我' : 'Me');
    if (_bestGuessCount == 0 || guessCount < _bestGuessCount) {
      await prefs.setInt('fun_best_guess_count', guessCount);
      await prefs.setString('fun_best_guess_user', username);
      setState(() {
        _bestGuessCount = guessCount;
        _bestGuessUser = username;
      });
    }
  }

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
    _loadChatMessages();
    _loadLeaderboard(); // Load leaderboard on init
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

  void _sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = Localizations.localeOf(context).languageCode;
    final username = prefs.getString('currentUsername') ?? (lang == 'zh' ? '我' : 'Me');
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add({'user': username, 'msg': text});
      _chatController.clear();
    });
    await _saveChatMessages();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.funInteraction),
        backgroundColor: const Color(0xFF16a951),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 入口按钮移到顶部
                Card(
                  color: const Color(0xFFe0f7fa),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showChatRoom = true;
                            });
                          },
                          child: Text(lang == 'zh' ? '聊天室' : 'Chatroom'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16a951),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _startGuessNumberGame,
                          child: Text(lang == 'zh' ? '猜数字' : 'Guess Number'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _loadLeaderboard();
                            setState(() {
                              _showLeaderboard = true;
                            });
                          },
                          child: Text(lang == 'zh' ? '排行榜' : 'Leaderboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
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
                const SizedBox(height: 20),
              ],
            ),
          ),
          // 聊天室弹窗
          if (_showChatRoom)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    child: SizedBox(
                      width: 350,
                      height: 500,
                      child: Column(
                        children: [
                          Container(
                            color: const Color(0xFF16a951),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(lang == 'zh' ? '聊天室' : 'Chatroom', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _showChatRoom = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _chatMessages.length,
                              itemBuilder: (context, idx) {
                                final msg = _chatMessages[idx];
                                return Align(
                                  alignment: msg['user'] == (lang == 'zh' ? '我' : 'Me') ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: msg['user'] == (lang == 'zh' ? '我' : 'Me') ? const Color(0xFF16a951) : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${msg['user']}: ${msg['msg']}',
                                      style: TextStyle(color: msg['user'] == (lang == 'zh' ? '我' : 'Me') ? Colors.white : Colors.black),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    decoration: InputDecoration(
                                      hintText: lang == 'zh' ? '说点什么...' : 'Say something...',
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.send, color: Color(0xFF16a951)),
                                  onPressed: _sendMessage,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // 猜数字弹窗
          if (_showGuessNumber)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    child: SizedBox(
                      width: 350,
                      height: 340,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(lang == 'zh' ? '猜数字小游戏' : 'Guess Number Game', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _showGuessNumber = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  lang == 'zh' ? '我想了一个1~100的数字，快来猜猜吧！' : 'I have a number between 1 and 100. Try to guess it!',
                                  style: const TextStyle(fontSize: 16, color: Colors.black)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _guessController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: lang == 'zh' ? '输入你的猜测' : 'Enter your guess',
                                          border: const OutlineInputBorder(),
                                        ),
                                        onSubmitted: (_) => _submitGuess(lang),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _submitGuess(lang),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                      child: Text(lang == 'zh' ? '提交' : 'Submit'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(_guessFeedback, style: const TextStyle(fontSize: 16, color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // 排行榜弹窗
          if (_showLeaderboard)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    child: SizedBox(
                      width: 350,
                      height: 220,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(lang == 'zh' ? '排行榜' : 'Leaderboard', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _showLeaderboard = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: (_bestGuessCount == 0)
                                ? (Text(
                                    lang == 'zh' ? '暂无记录，快来挑战吧！' : 'No record yet, be the first!',
                                    style: const TextStyle(fontSize: 16, color: Colors.black)))
                                : (Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        lang == 'zh' ? '最佳成绩' : 'Best Score',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                      const SizedBox(height: 12),
                                      Text('$_bestGuessUser', style: const TextStyle(fontSize: 18, color: Colors.blue)),
                                      const SizedBox(height: 8),
                                      Text(
                                        lang == 'zh' ? '猜中次数：$_bestGuessCount' : 'Tries: $_bestGuessCount',
                                        style: const TextStyle(fontSize: 16, color: Colors.black)),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
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