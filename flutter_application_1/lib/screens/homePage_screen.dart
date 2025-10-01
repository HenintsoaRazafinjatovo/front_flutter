import 'package:flutter/material.dart';
import '../layout/main_layout.dart'; // ⚡ Assure-toi que ce fichier existe

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Modules',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 768;
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: isWide ? 2 : 1,
                            mainAxisSpacing: 30,
                            crossAxisSpacing: 30,
                            childAspectRatio: isWide ? 1.3 : 1.5,
                            children: [
                              // ⚡ Ouvre MainLayout avec module stock
                              ModuleCard(
                                icon: Icons.article_outlined,
                                title:
                                    'Gestion Stock des Matériels Administratifs',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainLayout(
                                        selectedModule: ModuleType.stock,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // ⚡ Ouvre MainLayout avec module immo
                              ModuleCard(
                                icon: Icons.warehouse_rounded,
                                title: 'Gestion des Immobilisations',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainLayout(
                                        selectedModule: ModuleType.immobilisation,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleCard extends StatefulWidget {
  final dynamic icon; // Peut être String (emoji) ou IconData
  final String title;
  final VoidCallback? onTap; // action au clic

  const ModuleCard({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFFF9B70D)
                  : const Color(0xFFF5F5F5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFFF9B70D).withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 40 : 20,
                offset: Offset(0, _isHovered ? 12 : 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHovered ? 1.0 : 0.0,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF9B70D), Color(0xFFE53E3E)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(_rotationAnimation.value)
                            ..scale(_scaleAnimation.value),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFF9B70D), Color(0xFFFFC940)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF9B70D)
                                      .withOpacity(_isHovered ? 0.4 : 0.3),
                                  blurRadius: _isHovered ? 30 : 25,
                                  offset: Offset(0, _isHovered ? 12 : 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: widget.icon is String
                                  ? Text(
                                      widget.icon,
                                      style: const TextStyle(fontSize: 40),
                                    )
                                  : Icon(
                                      widget.icon as IconData,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

