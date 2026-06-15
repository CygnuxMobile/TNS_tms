import 'package:flutter/material.dart';
import '../../widgets/app_size.dart';
import '../../widgets/tms_normaltext.dart';

class DashBoardContainer extends StatelessWidget {
  const DashBoardContainer(
      {Key? key, required this.text, required this.image, required this.ontap})
      : super(key: key);

  final String text;
  final String image;
  final VoidCallback ontap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey,width: 1),
          color: const Color(0xFFE9ECEF),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TmsText(
               text: text,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(
                height: 15,
              ),
              Image(
                image: AssetImage(image),
                height: AppSize.size(context).height * 0.09,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
