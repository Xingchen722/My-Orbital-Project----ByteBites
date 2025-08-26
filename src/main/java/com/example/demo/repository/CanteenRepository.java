package com.example.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.entity.Canteen;

public interface CanteenRepository extends JpaRepository<Canteen, String> {
}