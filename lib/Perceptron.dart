class Perceptron {
  List<Input> input;
  List<int> weight;
  int bias;
  String details = '';

  Perceptron({this.input, this.weight, this.bias});

  void evaluate() {
    int counter = 1;
    int index = 0;
    details += "initial weight: " +
        weight.toString() +
        ", initial bias: " +
        bias.toString() +
        "\n";
    while (counter != input.length) {
      Input p = input.elementAt(index);
      int n = p.multiply(weight) + bias;
      details += "\ninput " +
          (index + 1).toString() +
          " : " +
          p.values.toString() +
          "\n";
      if (hardlim(n) != p.target) {
        counter = 1;
        details += "Values will be updated from weight = " +
            weight.toString() +
            " and bias = " +
            bias.toString() +
            "\n";
        updateValues(p.target - hardlim(n), index);
        details += "To weight = " +
            weight.toString() +
            " and bias = " +
            bias.toString() +
            "\n";
      } else {
        details += "Good, nothing to be updated\n";
        counter++;
      }
      // details += "index = " +
      //     (index + 1).toString() +
      //     ", Counter = " +
      //     counter.toString() +
      //     "\n";
      index = (index == input.length - 1 ? 0 : ++index);
    }
    details += "Final weight: " +
        weight.toString() +
        ", and final bias: " +
        bias.toString() +
        "\n";
  }

  void updateValues(int e, int idx) {
    bias = bias + e;
    weight = addLists(weight, input.elementAt(idx), e);
  }

  List<int> addLists(List<int> a1, Input inp, int e) {
    List<int> res = [];
    for (int i = 0; i < inp.values.length; i++)
      res.add(a1.elementAt(i) + (inp.values[i] * e));
    return res;
  }

  int hardlim(int n) {
    return (n >= 0 ? 1 : 0);
  }
}

class Input {
  List<int> values;
  int target;

  Input({this.values, this.target});

  int multiply(List<int> weight) {
    int result = 0;
    for (int i = 0; i < values.length; i++) {
      result += (values[i] * weight[i]);
    }
    return result;
  }
}
