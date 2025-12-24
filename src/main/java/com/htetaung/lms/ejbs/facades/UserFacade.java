package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.User;
import com.htetaung.lms.exception.AuthenticationException;
import com.htetaung.lms.models.enums.UserRole;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.List;
import java.util.Optional;

@Stateless
public class UserFacade extends AbstractFacade<User>{

    public static final int MAX_ITEMS_PER_PAGE = 20;

    @PersistenceContext
    private EntityManager em;

    public static final int PAGE_SIZE = 10;

    public UserFacade() {
        super(User.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public Optional<User> findByUsername(String username) throws IllegalArgumentException {
        if (username == null || username.trim().isEmpty()) {
            return Optional.empty();
        }
        TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE LOWER(u.username) = LOWER(:username)", User.class);
        query.setParameter("username", username.trim());
        try {
            User user = query.getSingleResult();
            return Optional.of(user);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    public boolean isUsernameAvailable(String username){
        TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.username = :username", User.class);
        query.setParameter("username", username);
        Optional<User> user = Optional.ofNullable(query.getResultStream().findFirst().orElse(null));
        return !user.isPresent();
    }

    public List<User> searchByFullName(String fullName, int page) {
        TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE LOWER(u.fullName) LIKE :fullName ORDER BY u.fullName ASC", User.class);
        query.setParameter("fullName", "%" + fullName.toLowerCase() + "%");
        query.setFirstResult((page - 1) * PAGE_SIZE);
        query.setMaxResults(PAGE_SIZE);
        return query.getResultList();
    }

    public List<User> findAllUsers(int page) {
        TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u ORDER BY u.fullName ASC", User.class);
        query.setFirstResult((page - 1) * PAGE_SIZE);
        query.setMaxResults(PAGE_SIZE);
        return query.getResultList();
    }

    public List<User> findAllUsersWithRole(UserRole role, int page){
        TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE TYPE(u) = :role ORDER BY u.fullName ASC", User.class);
        query.setParameter("role", switch (role){
            case ADMIN -> com.htetaung.lms.models.Admin.class;
            case ACADEMIC_LEADER -> com.htetaung.lms.models.AcademicLeader.class;
            case LECTURER -> com.htetaung.lms.models.Lecturer.class;
            case STUDENT -> com.htetaung.lms.models.Student.class;
        });
        query.setFirstResult((page - 1) * PAGE_SIZE);
        query.setMaxResults(PAGE_SIZE);
        return query.getResultList();
    }
}
