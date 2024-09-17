import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainPageForUserState extends StatefulWidget {
  const MainPageForUserState({super.key});

  @override
  State<MainPageForUserState> createState() => MainPageForUser();
}

class MainPageForUser extends State<MainPageForUserState> {
  late double screenHeight;
  late double screenWidth;

  List<String> carBrandsList = [];
  List<String> carModelsList = [];
  List<dynamic> carBrandsListDynamic = [];
  List<dynamic> carListDynamic = [];
  Map<String, dynamic> allSeachedModels = {};

  bool representativeButtonVisibility = true;
  bool removeRepresentativeButtonVisibility = false;

  int selectedIndexOnDropdownList = 0;
  String selectedBrandOnDropdownList = "Escolha a marca";
  String selectedModelOnDropdownList = "Escolha o modelo";

  bool isBrandSelected = false;

  String yearProduction = "";
  TextEditingController yearTextField = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  Future<void> fetchDataFromAPI() async {
    final response = await http.post(
        Uri.parse('http://192.168.132.137:5000/return_marca'));
        
    if (!mounted) return;
    setState(() {
      carBrandsListDynamic = json.decode(response.body);

      for(int i = 0; i < carBrandsListDynamic.length; i++) {
        carBrandsList.add(carBrandsListDynamic[i]['marca']);
      }
    });
  }

  Future<void> fetchModelsFromBrand(String brand) async {
    final response = await http.post(Uri.parse('http://192.168.132.137:5000/return_modelo'),
        body: {
          'marca': brand,
        });

    if (!mounted) return;
    setState(() {
      carListDynamic = json.decode(response.body);

      for (int i = 0; i < carListDynamic.length; i++) {
        carModelsList.add(carBrandsListDynamic[i]['modelo']);
      }
    });
  }

  Future<void> fetchFinalSearch(String brand, String model, int year) async {

    if(brand == "Escolha a marca"){
      brand = "";
    }

    if(model == "Escolha o modelo"){
      model = "";
    }
    
    final response = await http.post(Uri.parse('http://192.168.132.137:5000/return_carro_avancado'),
        body: {
          'marca': brand,
          'modelo': model,
          'ano': year
        });

    if (!mounted) return;
    setState(() {
      allSeachedModels = json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    TextStyle dropdownStyle =
        const TextStyle(fontWeight: FontWeight.normal, color: Colors.black);

    /*SearchAnchor mainSearchBar() {
      return SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
        return SearchBar(
            controller: controller,
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
            onTap: () {
              controller.openView();
            },
            onChanged: (_) {
              controller.openView();
            },
            leading: const Icon(Icons.search));
      }, suggestionsBuilder:
              (BuildContext context, SearchController controller) {
        return List<ListTile>.generate(5, (int index) {
          final String item = 'item $index';
          return ListTile(
            //request fill
            title: Text(item),
            onTap: () {
              setState(() {
                controller.closeView(item);
              });
            },
          );
        });
      });
    }*/

    Center dropDownBrandsButton() {
      return Center(
        child: Container(
          constraints: const BoxConstraints(
              minWidth: 200,
              minHeight: 50,
            ),
          width: screenWidth * 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xfff9a72d)),
            color: Colors.white,
          ),
          child: Center(
            child: DropdownButton<String>(
              icon: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.arrow_circle_down_sharp)),
              style: dropdownStyle,
              items: carBrandsList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? selectedValueOnDropdownList) {
                setState(() {
                  selectedBrandOnDropdownList = selectedValueOnDropdownList!;
                  selectedIndexOnDropdownList = carBrandsList.indexOf(selectedValueOnDropdownList);
                  fetchModelsFromBrand(selectedBrandOnDropdownList);
                  if (!mounted) return;
                  isBrandSelected = true;
                });
              },
              hint: Center(
                  child:
                      Text(selectedBrandOnDropdownList, style: dropdownStyle)),
              dropdownColor: const Color(0xfff9a72d),
              underline: Container(),
            ),
          ),
        ),
      );
    }

    Center dropDownModelsButton() {
      return Center(
        child: Container(
          constraints: const BoxConstraints(
              minWidth: 200,
              minHeight: 50,
            ),
          width: screenWidth * 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xfff9a72d)),
            color: Colors.white,
          ),
          child: Center(
            child: DropdownButton<String>(
              icon: const Padding(
                  //Icon at tail, arrow bottom is default icon
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.arrow_circle_down_sharp)),
              style: dropdownStyle,
              items: carModelsList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value)),
                );
              }).toList(),
              onChanged: isBrandSelected
                  ? (String? selectedValueOnDropdownList) {
                      setState(() {
                        selectedModelOnDropdownList =
                            selectedValueOnDropdownList!;
                        selectedIndexOnDropdownList =
                            carModelsList.indexOf(selectedValueOnDropdownList);
                      });
                    }
                  : null,
              hint: Center(
                  child:
                      Text(selectedModelOnDropdownList, style: dropdownStyle)),
              dropdownColor: const Color(0xfff9a72d),
              underline: Container(),
            ),
          ),
        ),
      );
    }

    SizedBox yearOfProductionField() {
      return SizedBox(
        width: screenHeight * 0.1,
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly, // Apenas dígitos
            LengthLimitingTextInputFormatter(4), // Máximo de 4 dígitos
          ],
          onChanged: (text) {
            yearProduction = text;
          },
          textAlign: TextAlign.center,
          controller: yearTextField,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(20.0),
            ),
            labelText: 'Ano',
          ),
        ),
      );
    }

    ButtonTheme buttonSearchCar() {
      return ButtonTheme(
        minWidth: screenHeight * 0.2,
        height: screenHeight * 0.1,
        child: ElevatedButton(
          onPressed: () async {

            if (!mounted) return;
            await fetchFinalSearch(selectedBrandOnDropdownList, selectedModelOnDropdownList, int.parse(yearProduction));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff9a72d),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Pesquisar',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    Column returnListWithCars(index) {

      return Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
          ),
          width: screenHeight * 0.75,
          child: ListTile(
              title: Row(children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Text(
                    "${allSeachedModels['modelo_carro']}", //vai verificar se é representante, novo style
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, right: 10),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "Ano: ${allSeachedModels['ano_carro']}",
                        //style: idStyle,
                      ),
                    ),
                  ),
                ),
              ]),
              subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Marca: ${allSeachedModels[index]['marca_carro']}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 20),
                      child: Text(
                        "Motor: ${allSeachedModels[index]['motor_carro']}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Potência (HP): ${allSeachedModels[index]['potencia_hp_carro']} HP",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Torque máximo (kgfm): ${allSeachedModels[index]['torque_nm_carro']} kgfm",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Combustível: ${allSeachedModels[index]['combustivel_carro']}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Câmbio: ${allSeachedModels[index]['cambio_carro']}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Tração: ${allSeachedModels[index]['tracao_carro']}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Peso (Kg): ${allSeachedModels[index]['peso_carro']} Kg",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        //colocar dois consumos no db
                        "Consumo (Km/L): ${allSeachedModels[index]['consumo_km_l_carro']} Km/L",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Aceleração 0 a 100: ${allSeachedModels[index]['aceleracao_0_100_carro']} segundos",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Velocidade máxima (km/h): ${allSeachedModels[index]['velocidade_maxima_km_h_carro']} km/h",
                      ),
                    ),
                  ]),
              onTap: () async {
                //confirmPopUpDialog(context, sugestionListDynamic[index][0]);
              }),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 100),
          child: Divider(
            color: const Color(0xfff9a72d),
            height: 10.0,
          ),
        ),
      ]);
    }

    return Scaffold(
      backgroundColor: const Color(0xffedecf2),
      appBar: AppBar(
        title: const Text('Site de consulta de carros'),
        backgroundColor: const Color.fromARGB(255, 201, 158, 93),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.1),
              const Text(
                'Pesquise seu veículo',
                style: TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 20),
              //mainSearchBar(),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Alinhamento principal (eixo horizontal)
                children: <Widget>[
                  dropDownBrandsButton(),
                  const SizedBox(width: 20), // Espaçamento entre os ícones
                  dropDownModelsButton(),
                  const SizedBox(width: 20),
                  yearOfProductionField(),
                  const SizedBox(width: 20),
                  buttonSearchCar(), //botão de pesquisar
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: screenWidth * 0.5,
                height: screenHeight * 0.7,
                child:ListView.builder(
                  itemCount: allSeachedModels.length,
                  itemBuilder: (context, index) {
                    return returnListWithCars(index);
                  },
                )
              )
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xfff9a72d),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações de conta'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
