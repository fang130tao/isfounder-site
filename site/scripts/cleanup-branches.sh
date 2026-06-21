#!/bin/bash
# ========================================
# Git Branch Cleanup Script
# Unify branches to use 'main' instead of 'master'
# ========================================

set -e

echo "🔧 Cleaning up Git branches..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check current branch
current_branch=$(git branch --show-current)
echo "Current branch: $current_branch"

# Ensure we're on main branch
if [ "$current_branch" != "main" ]; then
    echo "Switching to main branch..."
    git checkout main
fi

# Option 1: Force merge master into main
echo ""
echo "Choose an option:"
echo "1) Force merge master into main (preserve both histories)"
echo "2) Delete master branch completely (recommended)"
echo "3) Skip and handle manually"
read -p "Enter your choice (1/2/3): " choice

case $choice in
    1)
        echo -e "${YELLOW}Merging master into main with --allow-unrelated-histories...${NC}"
        git merge master --allow-unrelated-histories -m "merge: combine master and main branches"
        
        # Check for conflicts
        if [ $? -ne 0 ]; then
            echo -e "${RED}Merge conflicts detected! Please resolve them manually.${NC}"
            echo "After resolving conflicts:"
            echo "  git add ."
            echo "  git commit"
            exit 1
        fi
        
        echo -e "${GREEN}✅ Successfully merged master into main${NC}"
        
        # Delete local master branch
        echo "Deleting local master branch..."
        git branch -D master
        
        # Delete remote master branch
        echo "Deleting remote master branch..."
        git push origin --delete master
        
        echo -e "${GREEN}✅ Branch cleanup complete!${NC}"
        ;;
        
    2)
        echo -e "${YELLOW}Deleting master branch completely...${NC}"
        
        # Delete local master branch
        git branch -D master
        
        # Delete remote master branch
        git push origin --delete master
        
        echo -e "${GREEN}✅ Master branch deleted. Only 'main' branch remains.${NC}"
        ;;
        
    3)
        echo -e "${YELLOW}Skipping cleanup. You can handle this manually.${NC}"
        echo ""
        echo "Manual commands:"
        echo "  # Force merge:"
        echo "  git merge master --allow-unrelated-histories"
        echo ""
        echo "  # Or delete master:"
        echo "  git branch -D master"
        echo "  git push origin --delete master"
        ;;
        
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

# Show final branch status
echo ""
echo "Final branch status:"
git branch -a

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Branch cleanup complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"