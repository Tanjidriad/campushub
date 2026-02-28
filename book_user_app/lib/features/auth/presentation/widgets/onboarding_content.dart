class OnboardingContent {
  final String image;
  final String title;
  final String description;
  final List<OnboardingStep>? steps;
  final bool isSplash;

  const OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
    this.steps,
    this.isSplash = false,
  });
}

class OnboardingStep {
  final String icon;
  final String title;
  final String description;

  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
