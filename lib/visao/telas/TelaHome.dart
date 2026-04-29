import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TelaUm extends StatefulWidget {
  const TelaUm({super.key, required this.title});

  final String title;

  @override
  State<TelaUm> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaUm> {
  List<Map<String, dynamic>> dias = [
    {"numero": "01", "semana": "Seg", "ativo": true},
    {"numero": "02", "semana": "Ter", "ativo": false},
    {"numero": "03", "semana": "Qua", "ativo": false},
    {"numero": "04", "semana": "Qui", "ativo": false},
    {"numero": "05", "semana": "Sex", "ativo": false},
    {"numero": "06", "semana": "Sáb", "ativo": false},
  ];

  List<Map<String, dynamic>> horarios = [
    {"hora": "08:00", "ativo": true},
    {"hora": "09:00", "ativo": true},
    {"hora": "10:00", "ativo": true},
    {"hora": "11:00", "ativo": true},
    {"hora": "13:00", "ativo": false},
    {"hora": "14:00", "ativo": true},
    {"hora": "15:00", "ativo": false},
    {"hora": "16:00", "ativo": true},
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1304));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE5B0A3),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text("Horários disponíveis"),
          ],
        ),
      ),
      body: Container(
        color: Color(0xFFFAF9F8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Data & Hora",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 10),

              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: dias.map((dia) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(context: context, builder:(BuildContext context){
                          return AlertDialog(
                            title: const Text('Funcionalidade'),
                            content: const Text('Alterar para os horários do dia'),
                            actions: [
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: const Text('ok'))
                            ],
                          );
                        }
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: dia['ativo']
                              ? Color(0xFFE5B0A3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dia['numero'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: dia['ativo']
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              dia['semana'],
                              style: TextStyle(
                                fontSize: 12,
                                color: dia['ativo']
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Horários disponíveis",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 15),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: horarios.map((hora) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: hora['ativo']
                          ? Color(0xFFE5B0A3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      hora['hora'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hora['ativo']
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}