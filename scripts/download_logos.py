"""
Python script to download football team logos and league logos from 1000logos.net
Usage: python scripts/download_logos.py
Requires: pip install requests beautifulsoup4

Simple approach:
- Finds div.post-img.small-post-img containers
- Gets title from <a> tag title attribute
- Gets image URL from <img> src attribute
- Downloads directly
"""

import os
import sys
import requests
from bs4 import BeautifulSoup
import time
from urllib.parse import urlparse
import re

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except:
        pass

# Disable SSL warnings
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def sanitize_filename(name):
    """Convert name to valid filename"""
    name = name.lower()
    name = re.sub(r'[^a-z0-9_-]', '_', name)
    name = re.sub(r'_+', '_', name)
    return name.strip('_')

def download_logo(url, save_path):
    """Download a logo from URL"""
    try:
        # Ensure URL is properly formatted
        if not url.startswith('http://') and not url.startswith('https://'):
            print(f"  Invalid URL format: {url}")
            return False
        
        # Skip if file already exists
        if os.path.exists(save_path):
            return True
            
        response = requests.get(
            url, 
            timeout=30, 
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            },
            verify=False,
            allow_redirects=True
        )
        if response.status_code == 200:
            with open(save_path, 'wb') as f:
                f.write(response.content)
            return True
        else:
            print(f"  HTTP {response.status_code} for {url}")
    except Exception as e:
        print(f"  Error downloading {url}: {e}")
    return False

def get_logo_urls_from_page(page_url, base_url):
    """Extract logo URLs from a page using the table structure"""
    logo_urls = {}
    
    try:
        print(f"Fetching: {page_url}")
        response = requests.get(
            page_url, 
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            }, 
            timeout=30,
            verify=False,
            allow_redirects=True
        )
        
        if response.status_code != 200:
            print(f"HTTP {response.status_code} for {page_url}")
            return logo_urls
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Find all elements with id starting with "post-"
        # Structure: #post-106 > table > tbody > tr:nth-child(1) > td > div > a > img
        post_containers = soup.find_all(id=re.compile(r'^post-\d+'))
        
        print(f"Found {len(post_containers)} post containers")
        
        # Also try finding by the div.post-img class as fallback
        if len(post_containers) == 0:
            post_containers = soup.find_all('div', class_=lambda x: x and ('post-img' in x or 'small-post-img' in x))
            print(f"Found {len(post_containers)} post containers by class")
        
        for idx, container in enumerate(post_containers):
            try:
                link = None
                
                # Try the table structure first: #post-106 > table > tbody > tr > td > div > a
                table = container.find('table')
                if table:
                    tbody = table.find('tbody')
                    if tbody:
                        first_tr = tbody.find('tr')
                        if first_tr:
                            first_td = first_tr.find('td')
                            if first_td:
                                div = first_td.find('div')
                                if div:
                                    link = div.find('a')
                
                # Fallback: find <a> directly in container or any div
                if not link:
                    link = container.find('a')
                
                if not link:
                    continue
                
                # Get title from <a> tag title attribute
                title = link.get('title', '')
                if not title:
                    # Try alt text from img as fallback
                    img = link.find('img')
                    if img:
                        title = img.get('alt', '')
                    if not title:
                        continue
                
                # Clean title (remove "Logo" suffix)
                # The sanitize_filename function already handles Unicode characters properly
                name = sanitize_filename(title.replace(' Logo', '').replace(' logo', ''))
                
                if not name:
                    continue
                
                # Find <img> tag inside the <a> tag
                img = link.find('img')
                if not img:
                    print(f"  [{idx+1}] {name} - No image found")
                    continue
                
                # Get image URL - try data-src, data-lazy-src, or src (in that order)
                logo_url = img.get('data-src', '') or img.get('data-lazy-src', '') or img.get('src', '')
                
                # Skip data: URLs - they're placeholders
                if not logo_url or logo_url.startswith('data:'):
                    print(f"  [{idx+1}] {name} - Skipping data: URL (src={img.get('src', '')[:50]}...)")
                    continue
                
                # Make absolute URL if needed
                if logo_url.startswith('/'):
                    logo_url = base_url + logo_url
                elif not logo_url.startswith('http'):
                    logo_url = base_url + '/' + logo_url.lstrip('/')
                
                # Ensure proper URL format
                if not logo_url.startswith('http://') and not logo_url.startswith('https://'):
                    print(f"  [{idx+1}] {name} - Invalid URL format: {logo_url}")
                    continue
                
                print(f"  [{idx+1}] {name} - {logo_url}")
                logo_urls[name] = logo_url
                
                # Small delay to be respectful
                time.sleep(0.1)
                
            except Exception as e:
                print(f"  Error processing container {idx+1}: {e}")
                continue
        
    except requests.exceptions.RequestException as e:
        print(f"Request error fetching {page_url}: {e}")
    except Exception as e:
        print(f"Error fetching {page_url}: {e}")
    
    return logo_urls

def main():
    base_url = 'https://1000logos.net'
    
    # Team logos pages
    team_pages = [
        f'{base_url}/soccer/',
        f'{base_url}/soccer/page/2/',
    ]
    
    # League logos pages
    league_pages = [
        f'{base_url}/sports-leagues/',
        f'{base_url}/sports-leagues/page/2/',
    ]
    
    # Create directories
    teams_dir = 'assets/teams'
    leagues_dir = 'assets/leagues'
    os.makedirs(teams_dir, exist_ok=True)
    os.makedirs(leagues_dir, exist_ok=True)
    print(f"Created directories: {teams_dir}, {leagues_dir}\n")
    
    # Download Team Logos
    print("=" * 60)
    print("DOWNLOADING TEAM LOGOS")
    print("=" * 60)
    all_team_logos = {}
    for page_url in team_pages:
        print(f"\nProcessing: {page_url}")
        logos = get_logo_urls_from_page(page_url, base_url)
        all_team_logos.update(logos)
        print(f"Found {len(logos)} team logos on this page")
    
    print(f"\nTotal team logos found: {len(all_team_logos)}")
    print("\nStarting team logo downloads...\n")
    
    if all_team_logos:
        success_count = 0
        fail_count = 0
        skip_count = 0
        
        for team_name, logo_url in all_team_logos.items():
            # Determine file extension from URL
            parsed = urlparse(logo_url)
            path = parsed.path.lower()
            if '.svg' in path:
                extension = 'svg'
            elif '.jpg' in path or '.jpeg' in path:
                extension = 'jpg'
            elif '.webp' in path:
                extension = 'webp'
            else:
                extension = 'png'
            
            filename = f"{team_name}.{extension}"
            filepath = os.path.join(teams_dir, filename)
            
            # Skip if file already exists
            if os.path.exists(filepath):
                skip_count += 1
                continue
            
            print(f"Downloading: {filename}...")
            if download_logo(logo_url, filepath):
                print(f"  [OK] Saved: {filename}")
                success_count += 1
            else:
                print(f"  [FAIL] Failed: {filename}")
                fail_count += 1
            
            time.sleep(0.3)
        
        print(f"\nTeam Logos - Success: {success_count}, Failed: {fail_count}, Skipped: {skip_count}, Total: {len(all_team_logos)}")
    else:
        print("No team logos found.")
    
    # Download League Logos
    print("\n" + "=" * 60)
    print("DOWNLOADING LEAGUE LOGOS")
    print("=" * 60)
    all_league_logos = {}
    for page_url in league_pages:
        print(f"\nProcessing: {page_url}")
        logos = get_logo_urls_from_page(page_url, base_url)
        all_league_logos.update(logos)
        print(f"Found {len(logos)} league logos on this page")
    
    print(f"\nTotal league logos found: {len(all_league_logos)}")
    print("\nStarting league logo downloads...\n")
    
    if all_league_logos:
        league_success = 0
        league_fail = 0
        league_skip = 0
        
        for league_name, logo_url in all_league_logos.items():
            # Determine file extension from URL
            parsed = urlparse(logo_url)
            path = parsed.path.lower()
            if '.svg' in path:
                extension = 'svg'
            elif '.jpg' in path or '.jpeg' in path:
                extension = 'jpg'
            elif '.webp' in path:
                extension = 'webp'
            else:
                extension = 'png'
            
            filename = f"{league_name}.{extension}"
            filepath = os.path.join(leagues_dir, filename)
            
            # Skip if file already exists
            if os.path.exists(filepath):
                league_skip += 1
                continue
            
            print(f"Downloading: {filename}...")
            if download_logo(logo_url, filepath):
                print(f"  [OK] Saved: {filename}")
                league_success += 1
            else:
                print(f"  [FAIL] Failed: {filename}")
                league_fail += 1
            
            time.sleep(0.3)
        
        print(f"\nLeague Logos - Success: {league_success}, Failed: {league_fail}, Skipped: {league_skip}, Total: {len(all_league_logos)}")
    else:
        print("No league logos found.")
    
    # Summary
    print("\n" + "=" * 60)
    print("DOWNLOAD SUMMARY")
    print("=" * 60)
    team_success = success_count if all_team_logos else 0
    team_fail = fail_count if all_team_logos else 0
    team_skip = skip_count if all_team_logos else 0
    league_success = league_success if all_league_logos else 0
    league_fail = league_fail if all_league_logos else 0
    league_skip = league_skip if all_league_logos else 0
    
    print(f"Team Logos:  {team_success} success, {team_fail} failed, {team_skip} skipped, {len(all_team_logos)} total")
    print(f"League Logos: {league_success} success, {league_fail} failed, {league_skip} skipped, {len(all_league_logos)} total")
    print(f"Grand Total: {team_success + league_success} success, {team_fail + league_fail} failed, {team_skip + league_skip} skipped")
    print(f"Total Files Found: {len(all_team_logos) + len(all_league_logos)}")
    print("=" * 60)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nDownload interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\nFatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
