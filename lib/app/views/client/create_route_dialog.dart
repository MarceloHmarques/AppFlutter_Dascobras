import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';

class CreateRouteDialog extends StatefulWidget {
  const CreateRouteDialog({super.key});

  @override
  State<CreateRouteDialog> createState() => _CreateRouteDialogState();
}

class _CreateRouteDialogState extends State<CreateRouteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _routeNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _authSession = AuthSessionService();
  final _supabase = Supabase.instance.client;

  List<String> _cities = []; 
  List<Map<String, dynamic>> _routesList = []; // Lista para exibir as rotas salvas
  
  bool _loading = false;
  bool _loadingRoutes = false;
  String? _errorMessage;
  
  // Controle de Edição
  String? _editingRouteId; 

  @override
  void initState() {
    super.initState();
    _loadRoutes(); // Carrega as rotas assim que o modal abre
  }

  // Busca as rotas ativas da empresa logada
  Future<void> _loadRoutes() async {
    setState(() => _loadingRoutes = true);
    try {
      final companyId = await _authSession.getCompanyId();
      final response = await _supabase
          .from('route')
          .select()
          .eq('company_id', companyId)
          .eq('is_active', true)
          .order('name');

      setState(() {
        _routesList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Erro ao carregar rotas: $e");
    } finally {
      setState(() => _loadingRoutes = false);
    }
  }

  void _addCity() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty && !_cities.contains(city)) {
      setState(() {
        _cities.add(city);
        _cityController.clear();
      });
    }
  }

  void _removeCity(int index) {
    setState(() {
      _cities.removeAt(index);
    });
  }

  // Prepara o formulário com os dados da rota selecionada para edição
  void _prepareEdit(Map<String, dynamic> route) {
    setState(() {
      _editingRouteId = route['id'].toString();
      _routeNameController.text = route['name'] ?? '';
      
      final description = route['description'] as String?;
      if (description != null && description.trim().isNotEmpty) {
        _cities = description.split(', ').map((c) => c.trim()).toList();
      } else {
        _cities = [];
      }
      _errorMessage = null;
    });
  }

  // Cancela o modo de edição limpando os campos
  void _cancelEdit() {
    setState(() {
      _editingRouteId = null;
      _routeNameController.clear();
      _cityController.clear();
      _cities = [];
      _errorMessage = null;
    });
  }

  // Salva (Insert) ou Atualiza (Update) a rota
  Future<void> _saveRoute() async {
    if (_cities.isEmpty) {
      setState(() {
        _errorMessage = "Adicione pelo menos uma cidade para esta rota.";
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final companyId = await _authSession.getCompanyId();

      if (_editingRouteId == null) {
        // 🚀 MODO: INSERÇÃO (NOVA ROTA)
        await _supabase.from('route').insert({
          'name': _routeNameController.text.trim(),
          'description': _cities.join(', '),
          'company_id': companyId,
          'is_active': true,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rota cadastrada com sucesso!")),
        );
      } else {
        // 🛠️ MODO: EDIÇÃO (ATUALIZAR EXISTENTE)
        await _supabase.from('route').update({
          'name': _routeNameController.text.trim(),
          'description': _cities.join(', '),
        }).eq('id', _editingRouteId!).eq('company_id', companyId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rota atualizada com sucesso!")),
        );
      }

      _cancelEdit();
      _loadRoutes(); // Recarrega a listagem atualizada
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = e.code == '42501' 
            ? "Acesso negado (RLS). Verifique as políticas do Supabase."
            : "Erro no banco: ${e.message}";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro inesperado: $e";
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Exclusão Lógica da Rota (is_active = false)
  Future<void> _deleteRoute(Map<String, dynamic> route) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Rota"),
        content: Text("Deseja realmente apagar a rota '${route['name']}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sim, Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final companyId = await _authSession.getCompanyId();
      await _supabase
          .from('route')
          .update({'is_active': false})
          .eq('id', route['id'])
          .eq('company_id', companyId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rota removida com sucesso!")),
      );

      if (_editingRouteId == route['id'].toString()) {
        _cancelEdit();
      }
      _loadRoutes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir rota: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(15),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85, // Evita estouro de layout
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0D3F87), width: 2),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  _editingRouteId == null ? "Criar Nova Rota" : "Editar Rota",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF0D3F87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _routeNameController,
                decoration: InputDecoration(
                  labelText: "Nome da Rota (Ex: Rota 1)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? "Insira o nome da rota" : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: "Adicionar Cidade",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onFieldSubmitted: (_) => _addCity(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3F87),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _addCity,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text(
                "Cidades inclusas nesta rota:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D3F87)),
              ),
              const SizedBox(height: 5),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _cities.isEmpty
                    ? [const Text("Nenhuma cidade adicionada ainda.", style: TextStyle(color: Colors.grey, fontSize: 13))]
                    : List.generate(_cities.length, (index) {
                        return Chip(
                          label: Text(_cities[index], style: const TextStyle(fontSize: 12)),
                          backgroundColor: const Color(0xFF0D3F87).withOpacity(0.1),
                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.red),
                          onDeleted: () => _removeCity(index),
                        );
                      }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ],

              const SizedBox(height: 15),

              Row(
                children: [
                  if (_editingRouteId != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: _loading ? null : _cancelEdit,
                        child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3F87),
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: _loading ? null : () {
                        if (!_formKey.currentState!.validate()) return;
                        _saveRoute();
                      },
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_editingRouteId == null ? "Salvar Rota" : "Atualizar Rota", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              const Divider(color: Color(0xFF0D3F87), thickness: 1),
              const SizedBox(height: 10),
              
              const Text(
                "Rotas Cadastradas",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D3F87)),
              ),
              const SizedBox(height: 5),

              // Seção inferior com rolagem independente listando as rotas salvas
              Expanded(
                child: _loadingRoutes
                    ? const Center(child: CircularProgressIndicator())
                    : _routesList.isEmpty
                        ? const Center(child: Text("Nenhuma rota cadastrada.", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _routesList.length,
                            itemBuilder: (context, index) {
                              final route = _routesList[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                elevation: 1,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  title: Text(route['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(
                                    route['description'] ?? 'Sem cidades',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                                        onPressed: () => _prepareEdit(route),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _deleteRoute(route),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}