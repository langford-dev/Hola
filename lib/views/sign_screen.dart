import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reflex/models/constants.dart';
import 'package:reflex/views/home_screen.dart';
import 'package:reflex/views/set_profile_photo_screen.dart';
import 'package:reflex/widgets/widget.dart';

class SignScreen extends StatefulWidget {
  @override
  _SignScreenState createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool loading = false;

  Future getUserData(resultUser) async {
    try {
      DocumentReference usersRef = kUsersRef.doc(resultUser.uid);

      await usersRef.get().then((doc) async {
        String _interestOne = doc.data()['interestOne'].toString();
        String _interestTwo = doc.data()['interestTwo'].toString();
        String _interestThree = doc.data()['interestThree'].toString();
        String _profileImg = doc.data()['profileImage'];
        String _about = doc.data()['aboutUser'];

        await kGetStorage.write('myInterestOne', _interestOne);
        await kGetStorage.write('myInterestTwo', _interestTwo);
        await kGetStorage.write('myInterestThree', _interestThree);
        await kGetStorage.write('myProfilePicture', _profileImg);
        await kGetStorage.write('myName', resultUser.displayName);
        await kGetStorage.write('myId', resultUser.uid);
        await kGetStorage.write('myAbout', _about);

        Get.offAll(() => HomeScreen());
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }

      singleButtonDialogue('Sorry, an unexpected error occured');
    }
  }

  Future loginUser() async {
    try {
      if (mounted) {
        setState(() {
          loading = true;
        });
      }

      UserCredential result =
          await kFirebaseAuthInstance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentReference usersRef = kUsersRef.doc(result.user.uid);

      await usersRef.get().then(
        (doc) async {
          if (doc.exists) getUserData(result.user);
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }

      if (e.code == 'user-not-found') {
        singleButtonDialogue(
          'Account no found. Create a new account',
        );
        Get.to(
          SetProfilePhotoScreen(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          ),
        );
      } else if (e.code == 'wrong-password') {
        singleButtonDialogue(
          'Oops, Wrong password',
        );
      } else {
        singleButtonDialogue(
          'Sorry, an error occured',
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        // bottomSheet: Container(
        //   color: Colors.white,
        //   height: 60,
        //   padding: EdgeInsets.all(10),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Container(),
        //       !loading
        //           ? signButton('Done', () {
        //               if (_passwordController.text.length > 1 &&
        //                   _emailController.text.length > 1)
        //                 loginUser();
        //               else
        //                 singleButtonDialogue('Please input your info.');
        //             })
        //           : Container(),
        //     ],
        //   ),
        // ),

        body: !loading
            ? SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height - 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: Image.asset('./assets/appLogo.png'),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: inputField(
                          _emailController,
                          'Your e-mail',
                          'An e-mail is required to join the network',
                          TextInputType.name,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        padding: EdgeInsets.all(15),
                        child: inputField(
                          _passwordController,
                          'Password',
                          '',
                          TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        padding: EdgeInsets.all(15),
                        child: signButton('Done', () {
                          if (_passwordController.text.isNotEmpty &&
                              _emailController.text.isNotEmpty)
                            loginUser();
                          else
                            singleButtonDialogue('Please input your info.');
                        }),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: myLoader(),
              ),
        // body: SingleChildScrollView(
        //   child: Container(
        //     height: MediaQuery.of(context).size.height,
        //     width: MediaQuery.of(context).size.width,
        //     child: !loading
        //         ? Column(
        //             children: [
        //               Expanded(
        //                 flex: 2,
        //                 child: Container(
        //                   width: MediaQuery.of(context).size.width,
        //                   color: kPrimaryColor,
        //                   child: Center(
        //                     child: CircleAvatar(
        //                       radius: 60,
        //                       backgroundColor: Colors.grey[100],
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //               Expanded(
        //                 flex: 3,
        //                 child: Container(
        //                   width: MediaQuery.of(context).size.width,
        //                   padding: EdgeInsets.all(30),
        //                   color: Colors.white,
        //                   child: Column(
        //                     children: [
        // inputField(
        //   _emailController,
        //   'Your e-mail',
        //   'An e-mail is required to join the network',
        //   TextInputType.name,
        // ),

        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           )

        //   ),
        // ),
      ),
    );
  }
}
