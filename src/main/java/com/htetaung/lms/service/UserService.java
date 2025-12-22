package com.htetaung.lms.service;

import com.htetaung.lms.entity.User;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;

import java.util.List;

@Stateless
public class UserService {
    @PersistenceContext
    private EntityManager em;

    // CREATE
    public User createUser(User user) {
        em.persist(user);
        return user;
    }

    public User createUser(String username, String password, User.Role role) {
        User user = new User(username, password, role);
        em.persist(user);
        return user;
    }

    public User createUser(String username, String password, User.Role role, String fullName, String email) {
        User user = new User(username, password, role);
        user.setFullName(fullName);
        user.setEmail(email);
        em.persist(user);
        return user;
    }

    // READ - Single User
    public User findById(Long id) {
        return em.find(User.class, id);
    }

    public User findByUsername(String username) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> root = cq.from(User.class);
        cq.select(root).where(cb.equal(root.get("username"), username));

        TypedQuery<User> query = em.createQuery(cq);
        List<User> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public User findByEmail(String email) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> root = cq.from(User.class);
        cq.select(root).where(cb.equal(root.get("email"), email));

        TypedQuery<User> query = em.createQuery(cq);
        List<User> results = query.getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    // READ - Multiple Users
    public List<User> findAll() {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> root = cq.from(User.class);
        cq.select(root);
        return em.createQuery(cq).getResultList();
    }

    public List<User> findByRole(User.Role role) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> root = cq.from(User.class);
        cq.select(root).where(cb.equal(root.get("role"), role));
        return em.createQuery(cq).getResultList();
    }

    public List<User> findAllWithPagination(int pageNumber, int pageSize) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> root = cq.from(User.class);
        cq.select(root);

        TypedQuery<User> query = em.createQuery(cq);
        query.setFirstResult((pageNumber - 1) * pageSize);
        query.setMaxResults(pageSize);
        return query.getResultList();
    }

    public long countUsers() {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Long> cq = cb.createQuery(Long.class);
        Root<User> root = cq.from(User.class);
        cq.select(cb.count(root));
        return em.createQuery(cq).getSingleResult();
    }

    public long countUsersByRole(User.Role role) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Long> cq = cb.createQuery(Long.class);
        Root<User> root = cq.from(User.class);
        cq.select(cb.count(root)).where(cb.equal(root.get("role"), role));
        return em.createQuery(cq).getSingleResult();
    }

    // UPDATE
    public User updateUser(User user) {
        return em.merge(user);
    }

    public User updateUserPassword(Long userId, String newPassword) {
        User user = findById(userId);
        if (user != null) {
            user.setPassword(newPassword);
            return em.merge(user);
        }
        return null;
    }

    public User updateUserProfile(Long userId, String fullName, String email) {
        User user = findById(userId);
        if (user != null) {
            user.setFullName(fullName);
            user.setEmail(email);
            return em.merge(user);
        }
        return null;
    }

    public User updateUserRole(Long userId, User.Role newRole) {
        User user = findById(userId);
        if (user != null) {
            user.setRole(newRole);
            return em.merge(user);
        }
        return null;
    }

    // DELETE
    public boolean deleteUser(Long userId) {
        User user = findById(userId);
        if (user != null) {
            em.remove(user);
            return true;
        }
        return false;
    }

    public boolean deleteUser(User user) {
        if (user != null && em.contains(user)) {
            em.remove(user);
            return true;
        } else if (user != null && user.getId() != null) {
            User managedUser = findById(user.getId());
            if (managedUser != null) {
                em.remove(managedUser);
                return true;
            }
        }
        return false;
    }

    public int deleteUsersByRole(User.Role role) {
        List<User> users = findByRole(role);
        for (User user : users) {
            em.remove(user);
        }
        return users.size();
    }

    // UTILITY METHODS
    public boolean usernameExists(String username) {
        return findByUsername(username) != null;
    }

    public boolean emailExists(String email) {
        return findByEmail(email) != null;
    }

    public List<User> searchUsersByUsername(String searchTerm) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> root = cq.from(User.class);
        cq.select(root).where(cb.like(cb.lower(root.get("username")), "%" + searchTerm.toLowerCase() + "%"));
        return em.createQuery(cq).getResultList();
    }

    public List<User> searchUsersByFullName(String searchTerm) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> root = cq.from(User.class);
        cq.select(root).where(cb.like(cb.lower(root.get("fullName")), "%" + searchTerm.toLowerCase() + "%"));
        return em.createQuery(cq).getResultList();
    }
}
