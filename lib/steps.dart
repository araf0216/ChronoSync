import 'package:shadcn_flutter/shadcn_flutter.dart';

class ClockSteps extends StatelessWidget {
  const ClockSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Steps(
        children: [
          StepItem(
            title: Text('Create a project'),
            content: [
              Text('Create a new project in the project manager.'),
              Text('Add the required files to the project.'),
            ],
          ),
          StepItem(
            title: Text('Add dependencies'),
            content: [
              Text('Add the required dependencies to the project.'),
            ],
          ),
          StepItem(
            title: Text('Run the project'),
            content: [
              Text('Run the project in the project manager.'),
            ],
          ),
        ],
      ),
    );
  }
}