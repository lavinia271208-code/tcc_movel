import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//tela de SOLICITAÇÃO

class TelaDois extends StatefulWidget {
  const TelaDois({super.key, required this.title});

  final String title;

  @override
  State<TelaDois> createState() => _TelaDoisState();
}

class _TelaDoisState extends State<TelaDois> {

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
            Text("Solicitar horário"),
          ],
        ),
      ),
      body: Container(
        color: Color(0xFFFAF9F8),
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20),

            //horário
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Color(0xFFE5B0A3)),
                  SizedBox(width: 10),
                  Text(
                    "14:00 - Segunda-feira",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            //nome
            TextField(
              decoration: InputDecoration(
                labelText: "Seu nome",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            //email
            TextField(
              decoration: InputDecoration(
                labelText: "Seu e-mail",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            //serviço
            TextField(
              decoration: InputDecoration(
                labelText: "Serviço desejado",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            //botão
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE5B0A3),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  //simulação
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Solicitação enviada!"),
                    ),
                  );
                },
                child: Text(
                  "Enviar solicitação",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}