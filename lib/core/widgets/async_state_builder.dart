import 'package:flutter/material.dart';
import 'package:strop_admin_panel/core/state/data_state.dart';

/// Widget reutilizable para renderizar UI basada en un estado asíncrono
class AsyncStateBuilder extends StatelessWidget {
  final DataState state;
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder successBuilder;
  final Widget Function(BuildContext, String?)? errorBuilder;
  final String? errorMessage;

  const AsyncStateBuilder({
    super.key,
    required this.state,
    required this.loadingBuilder,
    required this.successBuilder,
    this.errorBuilder,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case DataState.loading:
        return loadingBuilder(context);
      case DataState.success:
        return successBuilder(context);
      case DataState.error:
        if (errorBuilder != null) return errorBuilder!(context, errorMessage);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              errorMessage ?? 'Ocurrió un error.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      case DataState.initial:
        // initial: show loading by default (caller can override)
        return loadingBuilder(context);
    }
  }
}
