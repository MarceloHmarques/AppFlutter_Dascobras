import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFF0D3F87), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,
        elevation: 0,

        selectedItemColor: const Color(0xFF0D3F87),
        unselectedItemColor: const Color(0xFF0D3F87),

        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_outlined, 0),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.people_outline, 1),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.shopping_cart_outlined, 2),
            label: 'Venda',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.bar_chart_outlined, 3),
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    final bool selected = currentIndex == index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: selected
          ? BoxDecoration(
              color: const Color(0xFF0D3F87),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Icon(
        icon,
        color: selected ? Colors.white : const Color(0xFF0D3F87),
      ),
    );
  }
}
