import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_state.freezed.dart';

@freezed
abstract class NavigationState with _$NavigationState {
  const factory NavigationState.home() = Home;
  const factory NavigationState.emailNotVerified() = EmailNotVerified;
  const factory NavigationState.unauthenticated() = Unauthenticated;
  const factory NavigationState.loading() = Loading;
  const factory NavigationState.error(Object error) = Error;
}
