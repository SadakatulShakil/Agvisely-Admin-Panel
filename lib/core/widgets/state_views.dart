import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../utils/resource.dart';

class LoadingBlock extends StatelessWidget {
  const LoadingBlock({super.key, this.height = 200});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    ),
  );
}

class ErrorBlock extends StatelessWidget {
  const ErrorBlock({
    super.key,
    required this.message,
    this.onRetry,
    this.height = 200,
  });

  final String message;
  final VoidCallback? onRetry;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.textMuted,
                size: 32,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyBlock extends StatelessWidget {
  const EmptyBlock({
    super.key,
    required this.message,
    this.action,
    this.height = 180,
  });

  final String message;
  final Widget? action;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (action != null) ...[const SizedBox(height: 12), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders a [Resource]: spinner on first load, error with retry when
/// there's nothing to show, otherwise the data — with a thin progress bar
/// on top while a reload is in flight.
class ResourceView<T> extends StatelessWidget {
  const ResourceView({
    super.key,
    required this.resource,
    required this.builder,
    required this.onRetry,
    this.placeholderHeight = 220,
  });

  final Resource<T> resource;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;
  final double placeholderHeight;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = resource.data.value;
      final status = resource.status.value;
      if (data == null) {
        if (status == LoadStatus.error) {
          return ErrorBlock(
            message: resource.error.value ?? 'Couldn’t load this section.',
            onRetry: onRetry,
            height: placeholderHeight,
          );
        }
        return LoadingBlock(height: placeholderHeight);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 2,
            child:
                status == LoadStatus.loading
                    ? const LinearProgressIndicator(minHeight: 2)
                    : null,
          ),
          builder(data),
        ],
      );
    });
  }
}
