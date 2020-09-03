import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:perceptron_network/CustomShowDialog.dart';
import 'package:perceptron_network/Perceptron.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfFields;

  List<String> hints;

  List<TextInputType> types;

  List<TextEditingController> controllers;

  GlobalKey<FormState> key;

  List<Function> validator;

  Map<String, dynamic> data;

  @override
  void initState() {
    key = GlobalKey();
    data = {};
    numberOfFields = 2;
    hints = [
      'initial bias',
      'initial weight',
      'input 1',
      'input 2',
    ];
    types = [
      TextInputType.number,
      TextInputType.name,
      TextInputType.name,
      TextInputType.name,
    ];
    controllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    validator = [
      (String value) {
        if (value.isEmpty) return 'This field is required';
      },
      (String value) {
        if (value.isEmpty) return 'This field is required';
        List<String> numbers = value.split(' ');
        for (int i = 0; i < numbers.length; i++) {
          if (!isNumeric(numbers[i]))
            return 'Please separate each number with a space';
        }
      },
      (String value) {
        if (value.isEmpty) return 'This field is required';
        List<String> numbers = value.split(' ');
        List<String> weight = controllers[1].text.split(' ');
        if ((weight.length != numbers.length - 1 || weight[0].length == 0))
          return 'Matrix length does not match';
        for (int i = 0; i < numbers.length; i++) {
          if (!isNumeric(numbers[i]))
            return 'Please enter only numbers with space between';
        }
      },
      (String value) {
        if (value.isEmpty) return 'This field is required';
        List<String> numbers = value.split(' ');
        List<String> weight = controllers[1].text.split(' ');
        if ((weight.length != numbers.length - 1 || weight[0].length == 0))
          return 'Matrix length does not match';
        for (int i = 0; i < numbers.length; i++) {
          if (!isNumeric(numbers[i]))
            return 'Please enter only numbers with space between';
        }
      },
    ];
    super.initState();
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopWidget(context),
            _buildTextFields(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopWidget(context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(height: 50),
          SvgPicture.asset('assets/machine-learning.svg', color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Welcome to Perceptron Network evaluator',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Please provide this application with\neach input, initial weight and bias',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFields(context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Form(
            key: key,
            child: Column(
              children: [for (int i = 0; i < hints.length; i++) _textField(i)],
            ),
          ),
          SizedBox(height: 16),
          _buildAddButton(context),
          SizedBox(height: 12),
          _buildEvaluateButton(context),
        ],
      ),
    );
  }

  Widget _textField(int pos) {
    if (pos < 4) return _fieldBody(pos);
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        setState(() {
          numberOfFields--;
          hints.removeLast();
          types.removeLast();
          controllers.removeLast();
          validator.removeLast();
        });
      },
      child: _fieldBody(pos),
    );
  }

  Container _fieldBody(int pos) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: TextFormField(
        autofocus: false,
        keyboardType: types[pos],
        controller: controllers[pos],
        validator: validator[pos],
        onSaved: (newValue) => data[hints[pos]] = newValue,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: hints[pos],
        ),
      ),
    );
  }

  Widget _buildAddButton(context) {
    return GestureDetector(
      onTap: () => setState(() {
        ++numberOfFields;
        hints.add('input $numberOfFields');
        types.add(TextInputType.name);
        controllers.add(TextEditingController());
        validator.add(
          (String value) {
            if (value.isEmpty) return 'This field is required';
            List<String> numbers = value.split(' ');
            List<String> weight = controllers[1].text.split(' ');
            if ((weight.length != numbers.length - 1 || weight[0].length == 0))
              return 'Matrix length does not match';
            for (int i = 0; i < numbers.length; i++) {
              if (!isNumeric(numbers[i]))
                return 'Please enter only numbers with space between';
            }
          },
        );
      }),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
        ),
        child: Text(
          'Add another input matrix',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEvaluateButton(context) {
    return GestureDetector(
      onTap: () {
        if (!key.currentState.validate()) return;
        key.currentState.save();
        showResult(context);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        width: 188,
        decoration: BoxDecoration(
          color: Color(0xffC1E3FC),
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Text(
          'Evaluate',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xff387AEA)),
        ),
      ),
    );
  }

  bool learnt = false;
  void showResult(context) {
    learnt = false;
    Function set;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          set = setState;
          return AlertDialog(
            title: Text(learnt ? 'Finished!' : 'Learning..'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearPercentIndicator(
                  percent: 1,
                  progressColor: Colors.blue,
                  animationDuration: 1500,
                  animation: true,
                ),
                learnt ? showDetails() : Container(),
              ],
            ),
          );
        });
      },
    );
    Future.delayed(Duration(milliseconds: 1500), () {
      set(() => learnt = true);
    });
  }

  Widget showDetails() {
    return GestureDetector(
      onTap: evaluateNetwork,
      child: Container(
        margin: EdgeInsets.only(top: 25),
        child: Container(
          // padding: EdgeInsets.all(16),
          width: 188,
          decoration: BoxDecoration(
            // color: Color(0xffC1E3FC),
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          child: Text(
            'Show details',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff5fb7f8)),
          ),
        ),
      ),
    );
  }

  void evaluateNetwork() {
    int bias = int.parse(data[hints[0]]);
    List<int> weight =
        data[hints[1]].toString().split(' ').map(int.parse).toList();
    List<Input> inputs = [];
    for (int i = 0; i < numberOfFields; i++) {
      List<int> inp =
          data[hints[i + 2]].toString().split(' ').map(int.parse).toList();
      int target = inp.last;
      inp.removeLast();
      inputs.add(Input(target: target, values: inp));
    }
    Perceptron network = Perceptron(bias: bias, input: inputs, weight: weight);
    network.evaluate();

    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: Text(network.details),
          ),
        ),
      ),
    );

    debugPrint(network.details);
  }
}
