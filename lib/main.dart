import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const FocusZoneApp());

const _green = Color(0xFF72F2A5);
const _amber = Color(0xFFFFC857);

class FocusZoneApp extends StatelessWidget {
  const FocusZoneApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FocusZone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF090B10),
          colorScheme: ColorScheme.fromSeed(
            seedColor: _green,
            brightness: Brightness.dark,
            surface: const Color(0xFF151922),
          ),
          useMaterial3: true,
        ),
        home: const MainNavigationScreen(),
      );
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [StudyModeScreen(), TimepassModeScreen()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories),
              label: 'Study',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined),
              selectedIcon: Icon(Icons.sports_esports),
              label: 'Play',
            ),
          ],
        ),
      );
}

class StudyModeScreen extends StatelessWidget {
  const StudyModeScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('FocusZone',
                style: TextStyle(color: _green, fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                tooltip: 'Focus timer',
                icon: const Icon(Icons.timer_outlined, color: _green),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const FocusTimerDialog(),
                ),
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.play_circle_outline), text: 'Study Shorts'),
                Tab(icon: Icon(Icons.menu_book_outlined), text: 'Study Hub'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ShortsFeed(items: _studyClips, accent: _green),
              StudyHubScreen(),
            ],
          ),
        ),
      );
}

class TimepassModeScreen extends StatelessWidget {
  const TimepassModeScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Fun Zone',
                style: TextStyle(color: _amber, fontWeight: FontWeight.w800)),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.movie_outlined), text: 'Fun Shorts'),
                Tab(icon: Icon(Icons.videogame_asset_outlined), text: 'Mini Games'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ShortsFeed(items: _funClips, accent: _amber),
              MiniGamesScreen(),
            ],
          ),
        ),
      );
}

class Reel {
  const Reel({required this.title, required this.creator, required this.caption, required this.url});
  final String title;
  final String creator;
  final String caption;
  final String url;
}

// These public Google sample videos demonstrate playback. Replace them with
// short videos you own or have permission to publish before releasing the app.
const _videoBase = 'https://storage.googleapis.com/gtv-videos-bucket/sample/';
const _studyClips = [
  Reel(title: 'Study smarter', creator: 'FocusZone Learn', caption: 'A quick study break: try 25 minutes of focused work, then rest.', url: '${_videoBase}ForBiggerEscapes.mp4'),
  Reel(title: 'Tiny science break', creator: 'Curious Minutes', caption: 'Short demo clip — add your own educational video here.', url: '${_videoBase}ForBiggerFun.mp4'),
  Reel(title: 'Keep your streak', creator: 'FocusZone Learn', caption: 'Small daily sessions add up. What are you learning today?', url: '${_videoBase}ForBiggerJoyrides.mp4'),
];
const _funClips = [
  Reel(title: 'Quick fun break', creator: 'FocusZone Picks', caption: 'Sample video for the demo feed. Take a quick screen break!', url: '${_videoBase}ForBiggerJoyrides.mp4'),
  Reel(title: 'Good vibes', creator: 'Daily Mix', caption: 'Demo clip — swap in licensed or original short videos.', url: '${_videoBase}ForBiggerEscapes.mp4'),
  Reel(title: 'One-minute reset', creator: 'Daily Mix', caption: 'Stretch, smile, and get back to what matters.', url: '${_videoBase}ForBiggerMeltdowns.mp4'),
];

class ShortsFeed extends StatefulWidget {
  const ShortsFeed({super.key, required this.items, required this.accent});
  final List<Reel> items;
  final Color accent;

  @override
  State<ShortsFeed> createState() => _ShortsFeedState();
}

class _ShortsFeedState extends State<ShortsFeed> {
  int _page = 0;

  @override
  Widget build(BuildContext context) => PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.items.length,
        onPageChanged: (page) => setState(() => _page = page),
        itemBuilder: (context, index) => ReelPage(
          key: ValueKey('${widget.items[index].url}-$index'),
          reel: widget.items[index],
          accent: widget.accent,
          active: index == _page,
        ),
      );
}

class ReelPage extends StatefulWidget {
  const ReelPage({super.key, required this.reel, required this.accent, required this.active});
  final Reel reel;
  final Color accent;
  final bool active;

  @override
  State<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _liked = false;
  bool _muted = false;
  bool _showPlay = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.url));
    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.setLooping(true);
      setState(() => _ready = true);
      if (widget.active) _controller.play();
    }).catchError((Object _) {
      if (mounted) setState(() => _ready = false);
    });
  }

  @override
  void didUpdateWidget(covariant ReelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_ready) return;
    if (widget.active) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (!_ready) return;
    setState(() => _showPlay = _controller.value.isPlaying);
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
    if (_showPlay) {
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _showPlay = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _togglePlayback,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF10131A)),
            if (_ready)
              Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              _VideoPlaceholder(accent: widget.accent),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x55000000), Colors.transparent, Color(0xCC000000)],
                  stops: [0, .45, 1],
                ),
              ),
            ),
            if (_showPlay)
              const Center(
                child: Icon(Icons.play_circle_fill, size: 78, color: Colors.white70),
              ),
            Positioned(
              top: 20,
              left: 18,
              right: 18,
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(widget.reel.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const Spacer(),
                  IconButton(
                    tooltip: _muted ? 'Unmute' : 'Mute',
                    onPressed: () {
                      setState(() => _muted = !_muted);
                      if (_ready) _controller.setVolume(_muted ? 0 : 1);
                    },
                    icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 90,
              bottom: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('@${widget.reel.creator}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(widget.reel.caption, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  const Row(children: [
                    Icon(Icons.music_note, size: 16),
                    SizedBox(width: 4),
                    Text('FocusZone audio · demo feed'),
                  ]),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 48,
              child: Column(
                children: [
                  _ActionButton(
                    icon: _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? Colors.redAccent : Colors.white,
                    label: _liked ? '1.3k' : '1.2k',
                    onTap: () => setState(() => _liked = !_liked),
                  ),
                  const SizedBox(height: 18),
                  _ActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comment',
                    onTap: () => _showComments(context),
                  ),
                  const SizedBox(height: 18),
                  _ActionButton(
                    icon: Icons.ios_share,
                    label: 'Share',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing will be available in a future update.')),
                    ),
                  ),
                ],
              ),
            ),
            if (_ready)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(playedColor: widget.accent),
                ),
              ),
          ],
        ),
      );

  void _showComments(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171B24),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Be the first to start a conversation.'),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Write a comment…',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => Navigator.pop(context),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withValues(alpha: .24), const Color(0xFF11141D), const Color(0xFF252032)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline, size: 74, color: Colors.white70),
              SizedBox(height: 10),
              Text('Video demo · connect to the internet', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color = Colors.white});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 66,
          child: Column(children: [
            Icon(icon, size: 31, color: color),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, style: const TextStyle(fontSize: 11)),
          ]),
        ),
      );
}

class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

  static const resources = [
    ('Focus routine', 'Plan a 25-minute study session', Icons.timer_outlined),
    ('Math practice', 'Quick practice ideas and revision prompts', Icons.calculate_outlined),
    ('Science notes', 'Organize your topics and key terms', Icons.science_outlined),
    ('Reading list', 'Save the books you want to explore', Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Your study space', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Simple tools to help you stay on track.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          for (final item in resources)
            Card(
              child: ListTile(
                leading: Icon(item.$3, color: _green),
                title: Text(item.$1),
                subtitle: Text(item.$2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.$1} selected')),
                ),
              ),
            ),
        ],
      );
}

class FocusTimerDialog extends StatefulWidget {
  const FocusTimerDialog({super.key});

  @override
  State<FocusTimerDialog> createState() => _FocusTimerDialogState();
}

class _FocusTimerDialogState extends State<FocusTimerDialog> {
  static const _startSeconds = 25 * 60;
  int _seconds = _startSeconds;
  Timer? _timer;

  void _toggle() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() => _timer = null);
      return;
    }
    setState(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_seconds <= 1) {
          timer.cancel();
          setState(() {
            _seconds = 0;
            _timer = null;
          });
        } else {
          setState(() => _seconds--);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return AlertDialog(
      title: const Text('Focus timer'),
      content: Text('$minutes:$seconds', textAlign: TextAlign.center, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
      actions: [
        TextButton(onPressed: () => setState(() { _timer?.cancel(); _timer = null; _seconds = _startSeconds; }), child: const Text('Reset')),
        FilledButton(onPressed: _seconds == 0 ? null : _toggle, child: Text(_timer == null ? 'Start' : 'Pause')),
      ],
    );
  }
}

class MiniGamesScreen extends StatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  State<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends State<MiniGamesScreen> {
  bool _memoryMode = false;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Tic-Tac-Toe'), icon: Icon(Icons.grid_3x3)),
                ButtonSegment(value: true, label: Text('Memory'), icon: Icon(Icons.extension)),
              ],
              selected: {_memoryMode},
              onSelectionChanged: (selection) => setState(() => _memoryMode = selection.first),
            ),
          ),
          Expanded(child: _memoryMode ? const MemoryGame() : const TicTacToeGame()),
        ],
      );
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> _board = List.filled(9, '');
  String _turn = 'X';
  String? _winner;

  static const _wins = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  void _play(int index) {
    if (_board[index].isNotEmpty || _winner != null) return;
    setState(() {
      _board[index] = _turn;
      if (_wins.any((line) => line.every((cell) => _board[cell] == _turn))) {
        _winner = _turn;
      } else if (_board.every((cell) => cell.isNotEmpty)) {
        _winner = 'Draw';
      } else {
        _turn = _turn == 'X' ? 'O' : 'X';
      }
    });
  }

  void _reset() => setState(() {
        _board = List.filled(9, '');
        _turn = 'X';
        _winner = null;
      });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_winner == null ? 'Player $_turn’s turn' : _winner == 'Draw' ? 'It’s a draw!' : 'Player $_winner wins!',
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemBuilder: (context, index) => InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _play(index),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: const Color(0xFF1A202B), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(_board[index], style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _board[index] == 'X' ? _green : _amber))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('New game')),
          ],
        ),
      );
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  static const _symbols = [Icons.star, Icons.favorite, Icons.catching_pokemon, Icons.lightbulb];
  final List<int> _cards = List.generate(8, (index) => index % 4)..shuffle(Random());
  final Set<int> _revealed = {};
  final Set<int> _matched = {};
  int _moves = 0;
  Timer? _hideTimer;

  void _tap(int index) {
    if (_revealed.contains(index) || _matched.contains(index) || _revealed.length == 2) return;
    setState(() {
      _revealed.add(index);
      if (_revealed.length == 2) {
        _moves++;
        final pair = _revealed.toList();
        if (_cards[pair[0]] == _cards[pair[1]]) {
          _matched.addAll(pair);
          _revealed.clear();
        } else {
          _hideTimer?.cancel();
          _hideTimer = Timer(const Duration(milliseconds: 800), () {
            if (mounted) setState(_revealed.clear);
          });
        }
      }
    });
  }

  void _reset() => setState(() {
        _hideTimer?.cancel();
        _cards.shuffle(Random());
        _revealed.clear();
        _matched.clear();
        _moves = 0;
      });

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_matched.length == _cards.length ? 'You matched them all in $_moves moves!' : 'Moves: $_moves', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemBuilder: (context, index) {
                  final faceUp = _revealed.contains(index) || _matched.contains(index);
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _tap(index),
                    child: Container(
                      decoration: BoxDecoration(color: faceUp ? const Color(0xFF263347) : const Color(0xFF1A202B), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Icon(faceUp ? _symbols[_cards[index]] : Icons.question_mark, color: faceUp ? _green : Colors.white70, size: 34)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('New game')),
          ],
        ),
      );
}
