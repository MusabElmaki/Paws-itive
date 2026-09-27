import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_config.dart';
import '../core/domain.dart';
import '../core/image_util.dart';
import '../core/services.dart';
import '../core/workflows.dart';
import 'workflow_pages.dart';
import '../core/cat_matching_service.dart';
import '../theme/app_theme.dart';

part 'auth_pages.dart';
part 'overview_pages.dart';
part 'report_pages.dart';
part 'donation_pages.dart';
part 'case_pages.dart';
part 'cat_pages.dart';
part 'shop_pages.dart';
part 'community_pages.dart';
part 'admin_pages.dart';
part 'notification_pages.dart';
