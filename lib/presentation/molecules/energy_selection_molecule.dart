import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_horizons/domain/controllers/controllers.dart';
import 'package:infinite_horizons/domain/objects/energy_level.dart';
import 'package:infinite_horizons/domain/objects/study_type_abstract.dart';
import 'package:infinite_horizons/presentation/atoms/atoms.dart';
import 'package:infinite_horizons/presentation/molecules/molecules.dart';
import 'package:infinite_horizons/presentation/pages/pages.dart';

class EnergySelectionMolecule extends StatefulWidget {
  const EnergySelectionMolecule(this.callback);

  final VoidCallback callback;

  @override
  State<EnergySelectionMolecule> createState() =>
      _EnergySelectionMoleculeState();
}

class _EnergySelectionMoleculeState extends State<EnergySelectionMolecule> {
  late EnergyLevel timerStates;

  @override
  void initState() {
    super.initState();
    timerStates = StudyTypeAbstract.instance!.getTimerStates();
  }

  void onChanged(EnergyType? type) {
    final EnergyType energy = type ?? EnergyType.undefined;
    StudyTypeAbstract.instance!.setTimerStates(energy);

    setState(() {
      timerStates = StudyTypeAbstract.instance!.getTimerStates();
    });
    widget.callback();
  }

  Widget energyWidget(EnergyType type) {
    final EnergyLevel timerStatesTemp = EnergyLevel.fromEnergyType(type);
    final StringBuffer subtitleBuffer = StringBuffer();

    final TimerSession firstTimerState = timerStatesTemp.sessions.first;

    for (final TimerSession timerState in timerStatesTemp.sessions) {
      if (timerState != firstTimerState) {
        subtitleBuffer.write(' -> ');
      }
      subtitleBuffer.write(
        '${timerState.study.inMinutes}m study -> ${timerState.breakDuration.inMinutes}m break',
      );
    }

    final bool showTipButton = timerStatesTemp.type.tipsId != null &&
        timerStatesTemp.type.tipsId!.isNotEmpty;

    return InkWell(
      onTap: () {
        VibrationController.instance.vibrate(VibrationType.light);
        onChanged(type);
      },
      child: ListTileAtom(
        '${type.previewName.tr()} - ${type.duration.inMinutes}${'minutes_single'.tr()}',
        titleIcon: type.icon,
        subtitle: subtitleBuffer.toString(),
        leading: Radio<EnergyType>(
          value: type,
          groupValue: timerStates.type,
          onChanged: onChanged,
        ),
        translateTitle: false,
        trailing: showTipButton
            ? IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EnergyTipsPage(timerStatesTemp.type),
                  ),
                ),
                icon: const FaIcon(FontAwesomeIcons.circleQuestion),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageEnclosureMolecule(
      title: 'energy',
      subTitle: 'Select session length',
      scaffold: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardAtom(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextAtom(
                    'recommended',
                    variant: TextVariant.smallTitle,
                  ),
                  const SeparatorAtom(),
                  energyWidget(EnergyType.efficient),
                ],
              ),
            ),
            const SeparatorAtom(variant: SeparatorVariant.farApart),
            CardAtom(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextAtom(
                    'custom',
                    variant: TextVariant.smallTitle,
                  ),
                  const SeparatorAtom(),
                  energyWidget(EnergyType.veryHigh),
                  energyWidget(EnergyType.high),
                  energyWidget(EnergyType.low),
                  energyWidget(EnergyType.veryLow),
                ],
              ),
            ),
            const SeparatorAtom(variant: SeparatorVariant.farApart),
            CardAtom(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextAtom(
                    'famous_methods',
                    variant: TextVariant.smallTitle,
                  ),
                  const SeparatorAtom(),
                  energyWidget(EnergyType.pomodoro),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
