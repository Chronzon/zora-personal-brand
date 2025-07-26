import 'package:flutter/material.dart';
import 'package:personal_branding_app/models/content_plan_item.dart';
import 'package:personal_branding_app/models/personal_brand.dart';

class BrandProvider extends ChangeNotifier {
  // Objek untuk menyimpan semua data identitas
  final PersonalBrand _brand = PersonalBrand();
  
  // Daftar untuk menyimpan hasil dari AI
  List<String> contentPillars = [];
  List<String> contentIdeas = [];
  
  // -- BARU: Daftar untuk menyimpan rencana konten --
  List<ContentPlanItem> contentPlans = [];
  
  // Status untuk menampilkan loading indicator
  bool isLoading = false;

  // Getter untuk mengakses data brand dari luar
  PersonalBrand get brand => _brand;

  // --- Fungsi untuk mengupdate setiap field di PersonalBrand ---

  void updateWhoAreYou(String value) {
    _brand.whoAreYou = value;
    notifyListeners(); // Memberi tahu UI untuk update
  }

  void updateMainSkill(String value) {
    _brand.mainSkill = value;
    notifyListeners();
  }

  void updatePassion(String value) {
    _brand.passion = value;
    notifyListeners();
  }

  void updateValues(String value) {
    _brand.values = value;
    notifyListeners();
  }

  void updateNicheTopic(String value) {
    _brand.nicheTopic = value;
    notifyListeners();
  }

  void updateTargetAudience(String value) {
    _brand.targetAudience = value;
    notifyListeners();
  }

  void updateProblemToSolve(String value) {
    _brand.problemToSolve = value;
    notifyListeners();
  }

  void updateBrandStatement(String value) {
    _brand.brandStatement = value;
    notifyListeners();
  }

  // --- Fungsi untuk mengatur hasil dari AI ---

  void setPillars(List<String> pillars) {
    contentPillars = pillars;
    notifyListeners();
  }

  void setIdeas(List<String> ideas) {
    contentIdeas = ideas;
    notifyListeners();
  }
  
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // -- BARU: Fungsi untuk mengelola Content Plan --
  void addContentPlan(ContentPlanItem item) {
    contentPlans.add(item);
    notifyListeners();
  }

  void updateContentPlan(ContentPlanItem updatedItem) {
    final index = contentPlans.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      contentPlans[index] = updatedItem;
      notifyListeners();
    }
  }

  void removeContentPlan(String id) {
    contentPlans.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}