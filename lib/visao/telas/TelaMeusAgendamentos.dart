import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/util/WidgetsUteis.dart';

class TelaTres extends StatefulWidget {
  const TelaTres({super.key, required this.title});

  final String title;

  @override
  State<TelaTres> createState() => _TelaTresState();
}

class _TelaTresState extends State<TelaTres> {
  final List<Map<String, String>> agendamentos = [
    {
      "dia": "Segunda-feira",
      "hora": "14:00",
      "servico": "Maquiagem",
      "status": "Confirmado"
    },
    {
      "dia": "Quarta-feira",
      "hora": "10:00",
      "servico": "Penteado",
      "status": "Pendente"
    },
    {
      "dia": "Sexta-feira",
      "hora": "16:00",
      "servico": "Maquiagem",
      "status": "Confirmado"
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            Text("Meus agendamentos"),
          ],
        ),
      ),

      body: Container(
        color: Color(0xFFFAF9F8),

        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: agendamentos.length,
          itemBuilder: (context, index) {

            final item = agendamentos[index];

            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //dia e hora
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Color(0xFFE5B0A3)),
                      SizedBox(width: 8),
                      Text(
                        "${item['dia']} - ${item['hora']}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  //serviço
                  Text(
                    "Serviço: ${item['servico']}",
                    style: TextStyle(fontSize: 14),
                  ),

                  SizedBox(height: 8),

                  //status
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 4, horizontal: 10
                    ),
                    decoration: BoxDecoration(
                      color: item['status'] == "Confirmado"
                          ? Color(0xFFE5B0A3)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['status']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
