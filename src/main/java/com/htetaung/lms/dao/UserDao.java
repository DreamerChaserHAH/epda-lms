package com.htetaung.lms.dao;

import com.htetaung.lms.entity.User;
import java.util.List;
import java.util.Optional;

public interface UserDao {
    void save(User user);
    Optional<User> findById(Long id);
    Optional<User> findByUsername(String username);
    List<User> findAll();
    void update(User user);
    void delete(Long id);
    boolean existsByUsername(String username);
    long countByUsername(String username);
}
