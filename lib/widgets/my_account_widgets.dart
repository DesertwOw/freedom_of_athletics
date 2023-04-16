import 'package:flutter/material.dart';


class EmailField extends StatelessWidget {
  const EmailField({Key? key, required this.emailController}) : super(key: key);

  final TextEditingController emailController;



  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: emailController,
      decoration: InputDecoration(
        hintText: 'insert@your.mail',
        prefixIcon: const Icon(Icons.mail),
        suffixIcon: emailController.text.isEmpty
            ? Container(width: 0)
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => emailController.clear(),
              ),
        labelText: 'Email',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
    );
  }
}

class ProfilePasswordField extends StatelessWidget {
  const ProfilePasswordField({Key? key, required this.passwordController}) : super(key: key);

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: passwordController,
      decoration: InputDecoration(
        hintText: 'Your new password',
        prefixIcon: const Icon(Icons.password),
        suffixIcon: passwordController.text.isEmpty
            ? Container(width: 0)
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => passwordController.clear(),
        ),
        labelText: 'Password',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
    );
  }
}

class NameInputField extends StatelessWidget {
  const NameInputField({Key? key, required this.nameController, required this.labelTexts,required this.name}) : super(key: key);

  final TextEditingController nameController;
  final String labelTexts;
  final String name;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: nameController,
      decoration: InputDecoration(
        hintText: name,
        prefixIcon: const Icon(Icons.face),
        suffixIcon: nameController.text.isEmpty
            ? Container(width: 0)
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => nameController.clear(),
        ),
        labelText: labelTexts,
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.done,
    );
  }
}



