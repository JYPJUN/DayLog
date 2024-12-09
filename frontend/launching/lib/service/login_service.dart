// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class LoginService {
//   Future<http.Response> saveUser(
//     String email, String password) async {
//       var uri = Uri.parse('http://i11b107.p.ssafy.io:8080/api/users/login');
//       Map<String, String> header = {"Content-Type": "application/json"};

//       Map data = {
//         'email': email,
//         'password': password,
//       };
//       var body = json.encode(data);
//       var response = await http.post(uri, headers: headers, body: body);
      
//       print(response.body);

//       return response;
//     }
//   );
// }
